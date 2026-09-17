#!/bin/bash

OUTPUT_FILE="requirements.txt"
COMBINED_TMP=$(mktemp)

# Collect all submodule requirements (skip the umbrella repo's own, already-generated output file)
find ./books -name "requirements.txt" | while read FILE; do
  echo "Adding dependencies from $FILE..."
  cat "$FILE" >> "$COMBINED_TMP"
  echo "" >> "$COMBINED_TMP"
done

# Deduplicate by package name: if a package appears both pinned (==) and unpinned,
# or with multiple different pins, keep the pinned version(s) and warn on conflicts.
python3 - "$COMBINED_TMP" "$OUTPUT_FILE" <<'PYEOF'
import sys, re
from collections import defaultdict

src, dst = sys.argv[1], sys.argv[2]
pkgs = defaultdict(set)  # name -> set of exact requirement lines (with or without pin)

with open(src) as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        m = re.match(r"^([A-Za-z0-9_.-]+)", line)
        if not m:
            continue
        name = m.group(1).lower()
        pkgs[name].add(line)

final = []
for name, variants in sorted(pkgs.items()):
    pinned = sorted(v for v in variants if "==" in v)
    if len(pinned) > 1:
        print(f"WARNING: conflicting pins for {name}: {pinned} -- keeping {pinned[-1]}", file=sys.stderr)
        final.append(pinned[-1])
    elif pinned:
        final.append(pinned[0])
    else:
        final.append(sorted(variants)[0])

with open(dst, "w") as f:
    for line in final:
        f.write(line + "\n")
PYEOF

rm -f "$COMBINED_TMP"
echo "Combined requirements written to $OUTPUT_FILE."