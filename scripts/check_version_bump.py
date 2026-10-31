#!/usr/bin/env python3
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def git(*args: str) -> str:
    return subprocess.run(["git", *args], cwd=ROOT, check=True, capture_output=True, text=True).stdout


def parse(version: str) -> tuple[int, ...]:
    return tuple(int(part) for part in version.split("."))


def main(base: str) -> int:
    merge_base = git("merge-base", base, "HEAD").strip()
    failed = False
    for manifest in sorted(ROOT.glob("plugins/*/.claude-plugin/plugin.json")):
        plugin_dir = manifest.parent.parent.relative_to(ROOT).as_posix()
        if not git("diff", "--name-only", merge_base, "HEAD", "--", plugin_dir).strip():
            continue
        head = json.loads(manifest.read_text(encoding="utf-8")).get("version")
        try:
            before = json.loads(git("show", f"{merge_base}:{plugin_dir}/.claude-plugin/plugin.json")).get("version")
        except subprocess.CalledProcessError:
            before = None
        if head is None:
            print(f"{plugin_dir}: plugin.json has no version", file=sys.stderr)
            failed = True
        elif before is not None and parse(head) <= parse(before):
            print(f"{plugin_dir}: changed but version {head} is not above {before}; bump it in plugin.json", file=sys.stderr)
            failed = True
    return 1 if failed else 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("usage: check_version_bump.py BASE_REF", file=sys.stderr)
        sys.exit(2)
    sys.exit(main(sys.argv[1]))
