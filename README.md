# Intel OpenVINO Whisper App for Home Assistant

This repository contains a custom Home Assistant app that exposes a local
Wyoming speech-to-text service backed by `whisper.cpp` with Intel OpenVINO.

It is intended for Intel iGPU systems where `/dev/dri/renderD128` is available.
The app starts:

- `whisper.cpp` HTTP inference server on internal port `8910`
- a Wyoming adapter on port `10300` for Home Assistant Assist

Default settings are intentionally conservative for first boot:

- model: `small`
- language: `en`
- OpenVINO device: `GPU`
- CPU fallback: enabled

After the app starts, add a Wyoming integration in Home Assistant pointing at
the app host and port `10300`, then select the discovered STT entity in the
Assist pipeline.

## Layout

- `repository.yaml`: Home Assistant app repository metadata
- `intel_openvino_whisper/`: app package

## Notes

Model files are stored under the app data directory at `/data/models`.
The first start downloads the selected Intel OpenVINO model archive, so it can
take a while.

The app maps `/dev/dri` via Home Assistant app configuration and disables
AppArmor because the Intel GPU/OpenVINO stack needs direct render-node access.
