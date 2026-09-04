#!/usr/bin/env python3
"""Verify that document references in this handbook resolve to real files.

The handbook cites other documents as bare filenames in backticks or bold —
`CONTRACT_SCHEMA.md`, **GITOPS_MODEL.md** — rather than as markdown links.
Link checkers do not see these, so a deleted or renamed document leaves
dangling citations that no CI job catches. This script closes that gap.

A reference resolves if the named path exists relative to the citing file's
directory, relative to the repository root, or as the tail of any document's
path — the handbook's convention is that a bare filename names that document
wherever it lives, which is why README.md can cite `CONTRACT_SCHEMA.md` for a
file in `_platform/`. Fenced code blocks are skipped, so example output and
shell snippets do not produce false positives.

Exits non-zero and prints file:line for every reference that does not resolve.
"""

import re
import sys
from pathlib import Path

# `NAME.md` or **NAME.md**, optionally with a directory prefix.
REFERENCE = re.compile(r"`([A-Za-z0-9_./-]+\.md)`|\*\*([A-Za-z0-9_./-]+\.md)\*\*")
FENCE = re.compile(r"^\s*(```|~~~)")


def references(path):
    """Yield (line_number, referenced_path) outside fenced code blocks."""
    in_fence = False
    for number, line in enumerate(path.read_text().splitlines(), start=1):
        if FENCE.match(line):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        for match in REFERENCE.finditer(line):
            yield number, match.group(1) or match.group(2)


def main():
    root = Path(__file__).resolve().parents[2]
    documents = [p for p in sorted(root.rglob("*.md")) if ".git" not in p.parts]
    known = {p.relative_to(root).as_posix() for p in documents}
    failures = []
    checked = 0

    def resolves(citing, target):
        if (citing.parent / target).exists() or (root / target).exists():
            return True
        # Bare filename naming a document elsewhere in the handbook.
        return any(k == target or k.endswith("/" + target) for k in known)

    for path in documents:
        for number, target in references(path):
            checked += 1
            if resolves(path, target):
                continue
            failures.append((path.relative_to(root), number, target))

    if failures:
        print(f"Dangling document references ({len(failures)} of {checked} checked):\n")
        for path, number, target in failures:
            print(f"  {path}:{number}  ->  {target}")
        print("\nEach reference must name a document that exists: relative to the citing")
        print("file, relative to the repository root, or by filename anywhere in the handbook.")
        return 1

    print(f"All {checked} document references resolve.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
