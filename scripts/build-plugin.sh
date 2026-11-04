#!/usr/bin/env bash
# build-plugin.sh - build persona-pain-points.plugin (the Cowork / Desktop upload artifact),
# then QA the artifact itself, not just the source.
#
# Usage: bash scripts/build-plugin.sh
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO"

# 1. Pre-build gates on the source tree
python3 scripts/check-frontmatter.py "$REPO" || { echo "Build aborted: frontmatter gate failed."; exit 1; }
bash scripts/qa-mechanical.sh "$REPO" || { echo "Build aborted: mechanical QA failed on source."; exit 1; }

# 2. Build. Manifest sits at the zip root (.claude-plugin/plugin.json), no wrapper folder.
python3 - <<'PY'
import os, zipfile, fnmatch
exclude_dirs = {'.git', '.githooks', '__pycache__', 'docs', '.claude'}
# The run-output folder is excluded at the repo root only; skills/pain-point-research/ is the skill itself.
exclude_top = {'pain-point-research'}
exclude_files = {'.DS_Store'}
count = 0
with zipfile.ZipFile('persona-pain-points.plugin', 'w', zipfile.ZIP_DEFLATED) as zf:
    for root, dirs, files in os.walk('.'):
        dirs[:] = sorted(d for d in dirs if d not in exclude_dirs and not (root == '.' and d in exclude_top))
        for f in sorted(files):
            if f in exclude_files or f.endswith('.plugin') or f.endswith('.pyc'):
                continue
            if fnmatch.fnmatch(f, 'test-*') or fnmatch.fnmatch(f, 'test_*'):
                continue
            path = os.path.join(root, f)
            zf.write(path, path[2:])
            count += 1
print(f"Built persona-pain-points.plugin - {count} files.")
PY

# 3. Post-build gate: unzip the artifact and run the same battery on it
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
unzip -q persona-pain-points.plugin -d "$TMP"
[ -f "$TMP/.claude-plugin/plugin.json" ] || { echo "Artifact has no .claude-plugin/plugin.json at its root."; exit 1; }
bash "$TMP/scripts/qa-mechanical.sh" "$TMP" || { echo "Build blocked: mechanical QA failed on the artifact. Do not commit it."; rm -f persona-pain-points.plugin; exit 1; }
echo "Artifact verified: persona-pain-points.plugin"
