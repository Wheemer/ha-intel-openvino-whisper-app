param(
    [string]$Version = "0.1.0",
    [string]$Arch = "amd64",
    [string]$ImageBase = "ghcr.io/wheemer"
)

$ErrorActionPreference = "Stop"

$image = "$ImageBase/$Arch-app-intel-openvino-whisper:$Version"

docker push $image

Write-Host "Published $image"
