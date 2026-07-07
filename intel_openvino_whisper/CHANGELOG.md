# Changelog

## 0.1.1

- Allow Intel OpenVINO `setupvars.sh` to run under the app startup script.

## 0.1.0

- Initial Home Assistant app package.
- Runs `whisper.cpp` with Intel OpenVINO.
- Exposes a Wyoming speech-to-text endpoint on port `10300`.
- Downloads selected `whisper.cpp` model on first start.
- Supports GPU startup with optional CPU fallback.
