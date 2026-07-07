# Intel OpenVINO Whisper

Local Wyoming speech-to-text for Home Assistant Assist, using `whisper.cpp`
with Intel OpenVINO acceleration.

The app listens on port `10300` using the Wyoming protocol. Add it in Home
Assistant as a Wyoming speech-to-text service and then choose the new STT
entity in your Assist pipeline.

## Build Model

Home Assistant should run this app from a prebuilt image:

`ghcr.io/wheemer/amd64-app-intel-openvino-whisper:<version>`

The image is built outside Home Assistant. Keep `version` in `config.yaml`
matched to the image tag.

From this repository on Windows:

```powershell
.\scripts\build-local.ps1
.\scripts\publish-ghcr.ps1
```

From Linux:

```bash
./scripts/build-local.sh
./scripts/publish-ghcr.sh
```

## First Start

The first start downloads the configured Intel OpenVINO Whisper model archive
into `/data/models`. Use `small` first on older Intel iGPU hardware, then test
larger models if latency is acceptable.

## Hardware

This app is designed for Intel systems exposing `/dev/dri/renderD128`.
It defaults to `openvino_device: GPU` and can retry with CPU if GPU startup
fails.
