# Whisper for Intel OpenVINO

Local Wyoming speech-to-text for Home Assistant Assist using `whisper.cpp` and
Intel OpenVINO GPU acceleration.

## Requirements

- Home Assistant OS on `amd64` Intel hardware.
- Intel integrated graphics exposed as `/dev/dri/renderD128`.
- Internet access on first start to download the selected model.

## Setup

1. Install the **Whisper for Intel OpenVINO** app.
2. Leave `openvino_device` set to `GPU`, choose a model, save, and start the app.
3. Wait for the first model download to finish.
4. Add the discovered Wyoming service under **Settings > Devices & services**.
5. Select its speech-to-text entity in **Settings > Voice assistants**.

The Wyoming endpoint listens on port `10300`. If discovery is unavailable, add
the Wyoming integration manually using the Home Assistant host address and port
`10300`.

## Options

| Option | Default | Purpose |
| --- | --- | --- |
| `model` | `small` | Whisper model downloaded on first start. |
| `language` | `en` | Recognition language. |
| `openvino_device` | `GPU` | OpenVINO execution device. |
| `fallback_to_cpu` | `true` | Retry on CPU if GPU initialization fails. |
| `beam_size` | `1` | Decoder beam size. |
| `threads` | `4` | CPU worker count. |
| `prompt` | empty | Optional recognition prompt. |
| `debug` | `false` | Detailed startup and GPU logging. |

Models live under `/data/models` and are excluded from app backups.

## Troubleshooting

- The first start can take several minutes while the model is downloaded.
- Confirm the app log lists `/dev/dri/renderD128` and an OpenVINO `GPU` device.
- Test `openvino_device: CPU` only as a diagnostic if GPU initialization fails.
- The Home Assistant STT entity can remain `unknown` until it processes audio.
  Run an Assist request and confirm a completed transcript in the app log.

Source, installation button, build status, and update policy are available on
the [repository home page](https://github.com/Wheemer/ha-intel-openvino-whisper-app).
