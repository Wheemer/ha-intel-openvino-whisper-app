# Architecture

This app intentionally uses an OpenVINO/OpenCL-style `whisper.cpp` backend
instead of the newer oneAPI/SYCL stack.

The target Home Assistant host observed during development was:

- CPU: Intel Core i7-7700T
- GPU path: `/dev/dri/renderD128`
- PCI path: `pci-0000:00:02.0-render`

That is Kaby Lake / HD Graphics 630-era hardware. Newer Intel voice Docker
projects are useful references, but many target Intel Arc, Iris Xe, or 11th-gen
and newer GPUs. This app starts from the older OpenVINO-compatible path because
it is more likely to work on the observed hardware.

The runtime has two local services in one Home Assistant app:

1. `whisper.cpp` HTTP inference server on `127.0.0.1:8910`
2. Wyoming API adapter on `0.0.0.0:10300`

Home Assistant talks only to the Wyoming endpoint.

## Borrowed Design

The service split follows the proven Docker pattern used by Intel GPU Wyoming
projects:

- persistent model directory
- `whisper.cpp` backend
- Wyoming adapter that POSTs audio to `/inference`

The HA app package collapses those services into a single container so it can be
installed and managed as one app.

## Build and Distribution

The Home Assistant host should not compile this image. `config.yaml` points to a
prebuilt GHCR image, and Home Assistant should only pull and run that versioned
image.

The local or CI build produces:

`ghcr.io/wheemer/amd64-app-intel-openvino-whisper:<version>`

The app `version` must match the image tag.

## Why Not The Newer SYCL Base?

The newer SYCL/Level-Zero base is attractive on modern Intel GPUs, but on the
observed i7-7700T host it is the wrong first risk. For this hardware, the more
compatible attempt is OpenVINO GPU with CPU fallback.
