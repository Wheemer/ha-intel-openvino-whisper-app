# Whisper for Intel OpenVINO
### GPU-accelerated local speech-to-text for Home Assistant Assist

[![Home Assistant App](https://img.shields.io/badge/HOME%20ASSISTANT-APP-41BDF5?style=for-the-badge&logo=home-assistant&logoColor=white&labelColor=555555)](https://www.home-assistant.io/apps/)
[![AMD64](https://img.shields.io/badge/AMD64-SUPPORTED-22C55E?style=for-the-badge&labelColor=555555)](https://github.com/Wheemer/ha-intel-openvino-whisper-app)
[![Latest release](https://img.shields.io/github/v/release/Wheemer/ha-intel-openvino-whisper-app?style=for-the-badge&logo=github&logoColor=white&label=RELEASE&labelColor=555555&color=22C55E)](https://github.com/Wheemer/ha-intel-openvino-whisper-app/releases/latest)
[![Publish](https://img.shields.io/github/actions/workflow/status/Wheemer/ha-intel-openvino-whisper-app/publish.yml?style=for-the-badge&label=BUILD&labelColor=555555)](https://github.com/Wheemer/ha-intel-openvino-whisper-app/actions/workflows/publish.yml)

Whisper for Intel OpenVINO provides a local Wyoming speech-to-text endpoint backed by
[`whisper.cpp`](https://github.com/ggml-org/whisper.cpp). It is built for Home
Assistant OS on `amd64` Intel systems and uses the integrated GPU through
OpenVINO while retaining an optional CPU fallback.

The app exposes Wyoming on port `10300`. Audio and transcripts stay on the
Home Assistant machine.

## Requirements

- Home Assistant OS with Apps support.
- An `amd64` Intel processor with an integrated GPU.
- A working `/dev/dri/renderD128` render device on the Home Assistant host.
- Internet access on first start to download the selected Whisper model.

This build avoids CPU-specific native instructions so it remains compatible
with older Intel processors while OpenVINO handles the encoder on the GPU.

The current image uses Ubuntu 26.04 and OpenVINO 2026.3. Intel HD 630 and other
Gen9 graphics devices use Intel's maintained `legacy1` compute runtime because
they are no longer included in the regular current-generation driver package.

## Installation

[![Add app repository to Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FWheemer%2Fha-intel-openvino-whisper-app)

1. Select the button above, or open **Settings > Apps > App store > Repositories**.
2. Add `https://github.com/Wheemer/ha-intel-openvino-whisper-app`.
3. Install **Whisper for Intel OpenVINO** from the app store.
4. Open **Configuration**, choose a model, and leave **OpenVINO device** set to `GPU`.
5. Start the app and wait for the first model download to complete.

## Connect Home Assistant

The app advertises itself through Wyoming discovery. Open **Settings > Devices &
services** and add the discovered **Whisper** service. If discovery is unavailable,
add the Wyoming integration manually using the Home Assistant host address and port
`10300`.

Then open **Settings > Voice assistants**, edit the desired Assist pipeline, and
select the new Whisper speech-to-text entity.

## Configuration

| Option | Default | Purpose |
| --- | --- | --- |
| `model` | `small` | Whisper model downloaded on first start. |
| `language` | `en` | Recognition language. |
| `openvino_device` | `GPU` | OpenVINO execution device: `GPU`, `CPU`, or `AUTO`. |
| `fallback_to_cpu` | `true` | Retry on CPU if GPU initialization fails. |
| `beam_size` | `1` | Decoder beam size; higher values trade speed for accuracy. |
| `threads` | `4` | CPU worker count used by `whisper.cpp`. |
| `prompt` | empty | Optional recognition prompt. |
| `debug` | `false` | Enable detailed GPU and startup diagnostics. |

Models are stored under `/data/models` and excluded from app backups.

## Troubleshooting

- A long first start normally means the model is still downloading and converting.
- Confirm the logs show `/dev/dri/renderD128` and an OpenVINO `GPU` device.
- If GPU initialization fails, enable `debug` and temporarily test with
  `openvino_device: CPU` to separate model problems from GPU access problems.
- An STT entity may show `unknown` until Home Assistant sends it audio. Verify it by
  running an Assist request and checking the app log for a completed transcript.

## Updates

GitHub checks pinned upstream sources every week. Dependency updates are proposed
as pull requests and built on a GitHub-hosted runner before they can be merged.
Merging a reviewed update publishes a new GHCR image; installing that update in
Home Assistant remains a manual decision.

## Development

The prebuilt image is published as
`ghcr.io/wheemer/amd64-app-intel-openvino-whisper:<version>`.

```powershell
.\scripts\build-local.ps1
.\scripts\publish-ghcr.ps1
```

```bash
./scripts/build-local.sh
./scripts/publish-ghcr.sh
```

Keep `intel_openvino_whisper/config.yaml` versioned to match the image tag.
