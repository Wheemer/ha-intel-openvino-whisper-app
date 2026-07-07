# Changelog

## 0.1.3

- Fix startup so `whisper.cpp` logs do not block the Wyoming adapter from launching.

## 0.1.2

- Use Ubuntu Jammy's older Intel OpenCL runtime for better Gen9/Kaby Lake compatibility.
- Log OpenCL and `/dev/dri` diagnostics when debug logging is enabled.

## 0.1.1

- Allow Intel OpenVINO `setupvars.sh` to run under the app startup script.

## 0.1.0

- Initial Home Assistant app package.
- Runs `whisper.cpp` with Intel OpenVINO.
- Exposes a Wyoming speech-to-text endpoint on port `10300`.
- Downloads selected `whisper.cpp` model on first start.
- Supports GPU startup with optional CPU fallback.
