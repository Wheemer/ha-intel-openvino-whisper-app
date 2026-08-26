# Changelog

## 0.1.9

- Clear a stale jemalloc preload preserved by Supervisor during in-place updates.

## 0.1.8

- Remove the jemalloc preload that conflicts with OpenVINO 2026 at runtime.

## 0.1.7

- Rename the app to Whisper for Intel OpenVINO and add official Whisper artwork.
- Upgrade the app base from Ubuntu 22.04 to Ubuntu 26.04.
- Upgrade OpenVINO from 2023.0 to 2026.3.
- Replace the old Jammy GPU packages with Intel's Gen9 `legacy1` compute runtime.
- Upgrade `whisper.cpp` from v1.9.2 to v1.9.3.

## 0.1.6

- Promote the tested app metadata from experimental to stable.
- Pin the Wyoming adapter source for reproducible builds.
- Add automated upstream dependency checks and cloud build validation.

## 0.1.5

- Upgrade `whisper.cpp` from v1.7.4 to v1.9.2 (ggml-org/whisper.cpp).

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
