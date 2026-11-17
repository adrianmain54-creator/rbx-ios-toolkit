#!/usr/bin/env python3
"""Validate a ClientAppSettings JSON file against a locally maintained allowlist.

This is a format/sanity check only. It cannot determine whether Roblox will honor
a flag and it does not bypass Roblox restrictions.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def load_json(path: Path):
    try:
        with path.open("r", encoding="utf-8") as handle:
            return json.load(handle)
    except (OSError, json.JSONDecodeError) as exc:
        raise ValueError(f"{path}: {exc}") from exc


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("settings", type=Path, help="ClientAppSettings JSON")
    parser.add_argument("--allowlist", required=True, type=Path,
                        help="JSON file containing an allowed_flags array")
    args = parser.parse_args()

    try:
        settings = load_json(args.settings)
        allowlist = load_json(args.allowlist)
    except ValueError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2

    if not isinstance(settings, dict):
        print("ERROR: settings must be a JSON object", file=sys.stderr)
        return 2
    allowed = allowlist.get("allowed_flags") if isinstance(allowlist, dict) else None
    if not isinstance(allowed, list) or not all(isinstance(x, str) for x in allowed):
        print("ERROR: allowlist must contain a string array named allowed_flags",
              file=sys.stderr)
        return 2

    unknown = sorted(set(settings) - set(allowed))
    if unknown:
        print("REJECTED: flags not present in your verified local allowlist:")
        for name in unknown:
            print(f"  - {name}")
        return 1

    print(f"OK: {len(settings)} setting(s) passed local allowlist validation.")
    print("This does not guarantee the Roblox client supports or applies them.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
