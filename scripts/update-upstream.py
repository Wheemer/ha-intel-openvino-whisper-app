#!/usr/bin/env python3
"""Update pinned Whisper sources and bump the Home Assistant app version."""

from __future__ import annotations

import json
import os
from pathlib import Path
import re
from urllib.request import Request, urlopen


ROOT = Path(__file__).resolve().parents[1]
DOCKERFILE = ROOT / "intel_openvino_whisper" / "Dockerfile"
CONFIG = ROOT / "intel_openvino_whisper" / "config.yaml"
CHANGELOG = ROOT / "intel_openvino_whisper" / "CHANGELOG.md"


def github_json(path: str):
    headers = {"Accept": "application/vnd.github+json", "User-Agent": "ha-app-updater"}
    token = os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    with urlopen(Request(f"https://api.github.com/{path}", headers=headers), timeout=30) as response:
        return json.load(response)


def version_tuple(value: str) -> tuple[int, ...]:
    match = re.fullmatch(r"v?(\d+)\.(\d+)\.(\d+)", value)
    return tuple(map(int, match.groups())) if match else ()


def bump_app_version() -> str:
    text = CONFIG.read_text(encoding="utf-8")
    match = re.search(r"^version:\s*(\d+)\.(\d+)\.(\d+)\s*$", text, re.MULTILINE)
    if not match:
        raise RuntimeError("Could not find app version in config.yaml")
    version = f"{match.group(1)}.{match.group(2)}.{int(match.group(3)) + 1}"
    CONFIG.write_text(text[: match.start()] + f"version: {version}" + text[match.end() :], encoding="utf-8")
    return version


dockerfile = DOCKERFILE.read_text(encoding="utf-8")
changes: list[str] = []

tags = github_json("repos/ggml-org/whisper.cpp/tags?per_page=100")
stable_tags = [item["name"] for item in tags if version_tuple(item["name"])]
latest_whisper = max(stable_tags, key=version_tuple)
current_whisper = re.search(r"^ARG WHISPER_CPP_REF=(\S+)$", dockerfile, re.MULTILINE).group(1)
if version_tuple(latest_whisper) > version_tuple(current_whisper):
    dockerfile = dockerfile.replace(
        f"ARG WHISPER_CPP_REF={current_whisper}", f"ARG WHISPER_CPP_REF={latest_whisper}"
    )
    changes.append(f"whisper.cpp {current_whisper} -> {latest_whisper}")

latest_client = github_json("repos/ser/wyoming-whisper-api-client/commits/main")["sha"]
current_client = re.search(r"^ARG WYOMING_CLIENT_REF=(\S+)$", dockerfile, re.MULTILINE).group(1)
if latest_client != current_client:
    dockerfile = dockerfile.replace(
        f"ARG WYOMING_CLIENT_REF={current_client}", f"ARG WYOMING_CLIENT_REF={latest_client}"
    )
    changes.append(f"Wyoming client {current_client[:8]} -> {latest_client[:8]}")

if changes:
    DOCKERFILE.write_text(dockerfile, encoding="utf-8")
    version = bump_app_version()
    changelog = CHANGELOG.read_text(encoding="utf-8")
    entry = f"\n## {version}\n\n" + "\n".join(f"- {change}." for change in changes) + "\n"
    CHANGELOG.write_text(changelog.replace("# Changelog\n", "# Changelog\n" + entry, 1), encoding="utf-8")
else:
    version = re.search(r"^version:\s*(\S+)$", CONFIG.read_text(encoding="utf-8"), re.MULTILINE).group(1)

output = os.environ.get("GITHUB_OUTPUT")
if output:
    with open(output, "a", encoding="utf-8") as handle:
        handle.write(f"changed={'true' if changes else 'false'}\n")
        handle.write(f"version={version}\n")

print("; ".join(changes) if changes else "Pinned upstream sources are current.")
