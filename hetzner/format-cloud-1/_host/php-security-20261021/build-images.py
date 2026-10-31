#!/usr/bin/env python3
"""Rebuild the reviewed runtime-only emergency images on an amd64 Docker host."""

import json
import subprocess
from pathlib import Path


root = Path(__file__).resolve().parent
for row in json.loads((root / "images.json").read_text()):
    args = ["docker", "build", "--progress=plain", "-t", row["image"]]
    for key, value in [
        ("BUILD_BASE", row["build_base"]),
        ("APP_BASE", row["app_base"]),
        ("PATCH_VERSION", row["php_version"]),
        ("PATCH_SHA256", row["php_sha256"]),
    ]:
        args += ["--build-arg", f"{key}={value}"]
    subprocess.run(args + [str(root)], check=True)
