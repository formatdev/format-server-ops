#!/usr/bin/env python3
"""Replace only reviewed service image lines in saved Portainer Compose files."""

import copy
import json
import re
import sys
from pathlib import Path

import yaml


for change in json.loads(Path(sys.argv[1]).read_text()):
    path = Path(change["path"])
    original = path.read_text()
    before = yaml.safe_load(original)
    service = change["service"]
    old_image = before["services"][service]["image"]
    expected = copy.deepcopy(before)
    expected["services"][service]["image"] = change["image"]
    pattern = r"(?m)^([ \t]*image:[ \t]*)" + re.escape(old_image) + r"[ \t]*$"
    revised, count = re.subn(
        pattern, lambda match: match[1] + change["image"], original
    )
    if count != 1 or yaml.safe_load(revised) != expected:
        raise RuntimeError(f"Unexpected Compose change for {path}")
    path.write_text(revised)
    print(f"{path}: {service} image updated")
