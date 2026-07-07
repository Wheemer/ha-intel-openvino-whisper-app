#!/usr/bin/env bash
set -Eeuo pipefail

CONFIG_PATH=/data/options.json
MODELS_DIR=/data/models
WHISPER_HOST=127.0.0.1
WHISPER_PORT=8910
WYOMING_URI=tcp://0.0.0.0:10300

log() {
    printf '[intel-openvino-whisper] %s\n' "$*" >&2
}

option() {
    local key=$1
    local default=$2
    jq -r --arg key "$key" --arg default "$default" '.[$key] // $default' "$CONFIG_PATH"
}

model="$(option model small)"
language="$(option language en)"
openvino_device="$(option openvino_device GPU)"
fallback_to_cpu="$(option fallback_to_cpu true)"
beam_size="$(option beam_size 1)"
threads="$(option threads 4)"
prompt="$(option prompt '')"
debug="$(option debug false)"

mkdir -p "$MODELS_DIR"

model_archive=""
case "$model" in
    base)
        model_archive="ggml-base-models.zip"
        ;;
    small)
        model_archive="ggml-small-models.zip"
        ;;
    small.en-tdrz)
        model_archive="ggml-small.en-tdrz-models.zip"
        ;;
    medium)
        model_archive="ggml-medium-models.zip"
        ;;
    large-v1)
        model_archive="ggml-large-v1-models.zip"
        ;;
    large-v2)
        model_archive="ggml-large-v2-models.zip"
        ;;
    large-v3)
        model_archive="ggml-large-v3-models.zip"
        ;;
    *)
        log "Unsupported OpenVINO model: ${model}"
        exit 1
        ;;
esac

model_path="$MODELS_DIR/ggml-${model}.bin"
if [[ ! -f "$model_path" ]]; then
    archive_path="$MODELS_DIR/${model_archive}"
    if [[ ! -f "$archive_path" ]]; then
        log "Downloading Intel OpenVINO model archive ${model_archive}; first start can take a while"
        wget -q "https://huggingface.co/Intel/whisper.cpp-openvino-models/resolve/main/${model_archive}" \
            -O "$archive_path"
    fi

    log "Extracting ${model_archive}"
    unzip -o "$archive_path" -d "$MODELS_DIR"
fi

if [[ ! -f "$model_path" ]]; then
    log "Expected model file not found after extraction: ${model_path}"
    exit 1
fi

if ! compgen -G "${MODELS_DIR}/ggml-${model}-encoder-openvino.*" >/dev/null; then
    log "OpenVINO encoder sidecar files were not found for ${model}; GPU startup may fail"
fi

source "/opt/intel/openvino_${OPENVINO_VERSION}/setupvars.sh"

server_args=(
    --model "$model_path"
    --language "$language"
    --threads "$threads"
    --beam-size "$beam_size"
    --host "$WHISPER_HOST"
    --port "$WHISPER_PORT"
    --ov-e-device "$openvino_device"
)

if [[ -n "$prompt" ]]; then
    server_args+=(--prompt "$prompt")
fi

if [[ "$debug" == "true" ]]; then
    server_args+=(--debug-mode)
fi

start_whisper() {
    log "Starting whisper.cpp on OpenVINO device ${openvino_device}"
    /opt/whisper.cpp/build/bin/whisper-server "${server_args[@]}" &
    echo $!
}

whisper_pid="$(start_whisper)"

sleep 5
if ! kill -0 "$whisper_pid" 2>/dev/null; then
    wait "$whisper_pid" || true
    if [[ "$fallback_to_cpu" == "true" && "$openvino_device" != "CPU" ]]; then
        log "GPU start failed; retrying with OpenVINO CPU because fallback_to_cpu=true"
        openvino_device=CPU
        for i in "${!server_args[@]}"; do
            if [[ "${server_args[$i]}" == "--ov-e-device" ]]; then
                server_args[$((i + 1))]=CPU
                break
            fi
        done
        whisper_pid="$(start_whisper)"
    else
        log "whisper.cpp failed to start"
        exit 1
    fi
fi

for _ in $(seq 1 60); do
    if nc -z "$WHISPER_HOST" "$WHISPER_PORT"; then
        break
    fi
    sleep 1
done

if ! nc -z "$WHISPER_HOST" "$WHISPER_PORT"; then
    log "whisper.cpp did not open ${WHISPER_HOST}:${WHISPER_PORT}"
    exit 1
fi

wyoming_args=(
    --uri "$WYOMING_URI"
    --api "http://${WHISPER_HOST}:${WHISPER_PORT}/inference"
    --model "$model"
)

if [[ "$debug" == "true" ]]; then
    wyoming_args+=(--debug)
fi

log "Starting Wyoming endpoint on 10300"
python3 -m wyoming_whisper_api_client "${wyoming_args[@]}" &
wyoming_pid=$!

term_handler() {
    log "Stopping"
    kill "$wyoming_pid" "$whisper_pid" 2>/dev/null || true
    wait "$wyoming_pid" "$whisper_pid" 2>/dev/null || true
}
trap term_handler TERM INT

set +e
wait -n "$wyoming_pid" "$whisper_pid"
exit_code=$?
set -e
term_handler
exit "$exit_code"
