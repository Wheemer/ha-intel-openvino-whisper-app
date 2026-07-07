param(
    [string]$Version = "0.1.0",
    [string]$Arch = "amd64",
    [string]$ImageBase = "ghcr.io/wheemer"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$appDir = Join-Path $repoRoot "intel_openvino_whisper"
$image = "$ImageBase/$Arch-app-intel-openvino-whisper:$Version"

docker build `
    --build-arg "BUILD_VERSION=$Version" `
    --build-arg "BUILD_ARCH=$Arch" `
    -t $image `
    $appDir

Write-Host "Built $image"
