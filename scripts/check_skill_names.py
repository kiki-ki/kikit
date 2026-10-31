#!/usr/bin/env python3
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
NAME = re.compile(r"^name:\s*['\"]?([^'\"\n]+?)['\"]?\s*$", re.MULTILINE)


def frontmatter(text: str) -> str | None:
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---\n", 4)
    return None if end == -1 else text[4:end]


def main() -> int:
    errors = []
    skills = sorted(ROOT.glob("plugins/*/skills/*/SKILL.md"))
    for path in skills:
        rel = path.relative_to(ROOT)
        fm = frontmatter(path.read_text(encoding="utf-8"))
        if fm is None:
            errors.append(f"{rel}: no frontmatter")
            continue
        match = NAME.search(fm)
        if match is None:
            errors.append(f"{rel}: no name in frontmatter")
        elif match.group(1) != path.parent.name:
            errors.append(f"{rel}: name {match.group(1)!r} does not match directory {path.parent.name!r}")
    for error in errors:
        print(error, file=sys.stderr)
    if not skills:
        print("no SKILL.md found", file=sys.stderr)
        return 1
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
