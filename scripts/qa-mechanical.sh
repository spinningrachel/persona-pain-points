#!/usr/bin/env bash
# qa-mechanical.sh - mechanical QA battery for persona-pain-points.
# Usage: bash scripts/qa-mechanical.sh <target-dir>
# <target-dir> is the repo root or an unzipped .plugin build. Exit 0 = all pass.
set -uo pipefail
TARGET="${1:?usage: qa-mechanical.sh <target-dir>}"
PASS=0; FAIL=0
SK="$TARGET/skills/pain-point-research"

report() { # id ok(1/0) detail
  if [ "$2" -eq 1 ]; then echo "CHECK $1: PASS"; PASS=$((PASS+1));
  else echo "CHECK $1: FAIL - $3"; FAIL=$((FAIL+1)); fi
}
has() { grep -qE "$1" "$2" 2>/dev/null; }          # pattern present
chk() { # id file pattern description
  if has "$3" "$2"; then report "$1" 1 ""; else report "$1" 0 "$4 (pattern '$3' missing in ${2#$TARGET/})"; fi
}
json_ok() { python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$1" 2>/dev/null; }

# 1. Manifests parse and carry required keys
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  if json_ok "$TARGET/$f"; then report "1:$f" 1 ""; else report "1:$f" 0 "not valid JSON or missing"; fi
done
python3 - "$TARGET/.claude-plugin/plugin.json" <<'PY' && report 2 1 "" || report 2 0 "plugin.json missing name/version/description/license"
import json,sys
d=json.load(open(sys.argv[1]))
assert all(d.get(k) for k in ("name","version","description","license")), d
PY

# 3. Version agrees between plugin.json and marketplace.json
python3 - "$TARGET" <<'PY' && report 3 1 "" || report 3 0 "version differs between plugin.json and marketplace.json"
import json,sys,os
t=sys.argv[1]
a=json.load(open(os.path.join(t,".claude-plugin/plugin.json")))["version"]
b=json.load(open(os.path.join(t,".claude-plugin/marketplace.json")))["plugins"][0]["version"]
assert a==b,(a,b)
PY

# 4. Frontmatter parses as YAML (the installer rejects the whole plugin otherwise)
FM_RC=0; python3 "$TARGET/scripts/check-frontmatter.py" "$TARGET" >/dev/null 2>&1 || FM_RC=$?
if [ "$FM_RC" -eq 0 ]; then report 4 1 ""; else report 4 0 "frontmatter gate failed (rc=$FM_RC); run scripts/check-frontmatter.py"; fi

# 5. Required files exist and are non-empty
for f in README.md CLAUDE.md CONNECTORS.md LICENSE agents/source-researcher.md agents/qa-plugin.md agents/quote-verifier.md agents/audience-fit-reviewer.md skills/pain-point-research/scripts/verify_quotes.py \
  skills/pain-point-research/SKILL.md skills/pain-point-research/scripts/build_workbook.py \
  skills/pain-point-research/references/deliverables.md skills/pain-point-research/references/source-groups.md \
  skills/pain-point-research/references/workbook-schema.md skills/pain-point-research/references/connectors.md \
  skills/pain-point-research/references/original-prompt.md; do
  if [ -s "$TARGET/$f" ]; then report "5:$f" 1 ""; else report "5:$f" 0 "missing or empty"; fi
done

# 6. Every references/ and scripts/ file named in SKILL.md exists
MISSING=""
for ref in $(grep -oE '(references|scripts)/[A-Za-z0-9_.-]+\.(md|py)' "$SK/SKILL.md" | sort -u); do
  [ -e "$SK/$ref" ] || MISSING="$MISSING $ref"
done
if [ -z "$MISSING" ]; then report 6 1 ""; else report 6 0 "SKILL.md references missing files:$MISSING"; fi

# 7. Workflow contract in SKILL.md
chk 7a "$SK/SKILL.md" "EXACT TARGET AUDIENCE" "intake must ask for the exact target audience"
chk 7b "$SK/SKILL.md" "SaaS founders with teams under 50 people" "intake must give the example"
chk 7c "$SK/SKILL.md" "PRODUCT CATEGORY" "intake must ask for the product category"
chk 7d "$SK/SKILL.md" "[Cc]ompetitive intelligence" "must request competitive intelligence"
chk 7e "$SK/SKILL.md" "Specificity check" "must block on a vague category"
chk 7f "$SK/SKILL.md" "every run" "must state intake runs every run (no saved state)"
chk 7g "$SK/SKILL.md" "fallback ladder" "must point to the connector fallback ladder"
chk 7h "$SK/SKILL.md" "Limitations" "must record skipped sources"
chk 7i "$SK/SKILL.md" "CLAUDE_PLUGIN_ROOT" "script path must use CLAUDE_PLUGIN_ROOT"
chk 7j "$SK/SKILL.md" "Never message, connect with, or comment" "read-only rule must be present"

# 8. Original prompt keeps all nine deliverables
N=$(grep -cE '^[1-9]\. ' "$SK/references/original-prompt.md" 2>/dev/null || echo 0)
if [ "${N:-0}" -ge 9 ]; then report 8 1 ""; else report 8 0 "original-prompt.md lists $N numbered items, need 9"; fi

# 9. Connectors doc: ladder present, review sites not scraped around, write tools forbidden
chk 9a "$SK/references/connectors.md" "Fallback ladder" "ladder missing"
chk 9b "$SK/references/connectors.md" "not part of this ladder" "review sites must be excluded from the ladder"
chk 9c "$SK/references/connectors.md" "Never use a scraper to log in" "scraper limits missing"
chk 9d "$SK/references/connectors.md" "Never message|never send|Never send" "LinkedIn write tools must be forbidden"

chk 9e "$TARGET/CONNECTORS.md" "not scraped around" "CONNECTORS.md must repeat the review-site rule"
if grep -qiE 'scraper (built )?for .*(G2|Capterra)' "$SK/references/connectors.md" 2>/dev/null; then report 9f 0 "connectors.md names G2/Capterra as scraper targets"; else report 9f 1 ""; fi
chk 9g "$SK/references/source-groups.md" "fallback ladder" "source-groups.md must point reddit and social at the ladder"

# 10. Cowork readiness
chk 10a "$TARGET/README.md" "Cowork" "README must cover Cowork"
chk 10b "$TARGET/CONNECTORS.md" "Cowork notes" "CONNECTORS.md must carry Cowork notes"
chk 10c "$TARGET/README.md" "Upload plugin" "README must describe the .plugin upload install"
if [ -d "$TARGET/.git" ] || [ -e "$TARGET/persona-pain-points.plugin" ] || [ ! -d "$TARGET/.git" ]; then
  # structure check applies to the build; in a repo the manifest must be at .claude-plugin/plugin.json
  if [ -f "$TARGET/.claude-plugin/plugin.json" ]; then report 10d 1 ""; else report 10d 0 "manifest not at .claude-plugin/plugin.json"; fi
fi

# 11. No hardcoded user paths in shipped text files
HITS=$(grep -rIlE '/Users/[A-Za-z0-9_.-]+/|C:\\Users\\' "$TARGET" --include='*.md' --include='*.json' --include='*.py' --include='*.sh' 2>/dev/null \
  | grep -vE '/(\.git|pain-point-research)/' | grep -vE 'qa-mechanical.sh|/CLAUDE.md$' || true)
if [ -z "$HITS" ]; then report 11 1 ""; else report 11 0 "hardcoded user path in: $(echo $HITS | tr '\n' ' ')"; fi

# 12. No run data or client names in what ships (in a git repo: tracked or not-ignored files only)
if [ -d "$TARGET/.git" ]; then
  FILES=$(cd "$TARGET" && git ls-files -co --exclude-standard 2>/dev/null)
else
  FILES=$(cd "$TARGET" && find . -type f | sed 's|^\./||')
fi
LEAK=""
echo "$FILES" | grep -q '^pain-point-research/' && LEAK="$LEAK pain-point-research/"
CLIENT=$(cd "$TARGET" && echo "$FILES" | grep -E '\.(md|json|py|sh)$' | grep -v 'qa-mechanical.sh' | xargs grep -Ili 'veriix' 2>/dev/null || true)
[ -n "$CLIENT" ] && LEAK="$LEAK client-name:$CLIENT"
if [ -z "$LEAK" ]; then report 12 1 ""; else report 12 0 "run data or client name in tree:$LEAK"; fi

# 13. No secrets
SEC=$(grep -rIE '(sk-[A-Za-z0-9]{20,}|gh[pousr]_[A-Za-z0-9]{30,}|AKIA[0-9A-Z]{16}|api[_-]?key[\"'"'"' ]*[:=][\"'"'"' ]*[A-Za-z0-9]{20,})' "$TARGET" --include='*' 2>/dev/null | grep -vE '/\.git/|qa-mechanical.sh|\.plugin' | head -3 || true)
if [ -z "$SEC" ]; then report 13 1 ""; else report 13 0 "possible secret: $(echo "$SEC" | head -1 | cut -c1-80)"; fi

# 14. Workbook script: compiles, builds the xlsx from a full fixture, falls back to CSV without openpyxl
TMP=$(mktemp -d)
cat > "$TMP/s.json" <<'JSON'
{"meta":{"audience":"a","category":"b","own_product":"p","date":"2026-01-01","competitors":["x"],"limitations":["l"]},
 "top10":[{"rank":1,"pain_point":"p","category":"c","frequency":1,"intensity":2.0,"summary":"s"}],
 "categories":[{"category":"c","frequency":1,"frequency_share":"1%","intensity":2.0,"business_impact":"High","impact_reason":"r","opportunity_score":5}],
 "category_detail":[{"category":"c","behavioral_patterns":"b","emotional_triggers":"e","competitor_mentions":"m","opportunity_score":5,"opportunity_rationale":"r"}],
 "quotes":[{"id":"Q001","category":"c","quote":"q","url":"https://example.com","platform":"reddit","date":"unknown","competitor":"","emotion":"anger","intensity":3,"speaker_role":"target","verification":"verified"}],
 "audience_fit":[{"metric":"verdict","value":"good","note":"n=1"}],
 "hidden_insights":[{"insight":"i","evidence":"e","quote_ids":"Q001"}],
 "competitor_gaps":[{"competitor":"c","pain_category":"p","how_they_fail":"h","evidence_quote_ids":"Q001"}],
 "language":{"vocabulary":[{"term":"t","type":"word","sources":1,"note":"n"}],"emotions":[{"emotion":"anger","share_pct":100}],"method_note":"m"},
 "action_matrix":[{"category":"c","quadrant":"quick_win","action":"a","next_step":"n","effort":"Low","opportunity_score":5,"evidence_quote_ids":"Q001"}],
 "sources":[{"type":"thread","name":"n","url":"https://example.com","platform":"reddit","cited_in":"Q001"}]}
JSON
if python3 -c "import py_compile,sys; py_compile.compile(sys.argv[1], cfile=sys.argv[2], doraise=True)" "$SK/scripts/build_workbook.py" "$TMP/bw.pyc" 2>/dev/null; then report 14a 1 ""; else report 14a 0 "build_workbook.py does not compile"; fi
if python3 "$SK/scripts/build_workbook.py" "$TMP/s.json" "$TMP/o.xlsx" >/dev/null 2>&1 && [ -s "$TMP/o.xlsx" -o -d "$TMP/o" ]; then report 14b 1 ""; else report 14b 0 "build_workbook.py failed on a full fixture"; fi
python3 - "$TMP/o.xlsx" <<'PY' && report 14c 1 "" || report 14c 0 "xlsx missing expected sheets (or openpyxl absent: CSV fallback used)"
import sys
try:
    from openpyxl import load_workbook
except ImportError:
    sys.exit(0)
wb=load_workbook(sys.argv[1])
need={"Summary","Audience Fit","Top 10","Categories","Category Detail","Quotes","Hidden Insights","Competitor Gaps","Action Matrix","Sources","Language"}
assert need<=set(wb.sheetnames), set(wb.sheetnames)
PY
# CSV fallback path: run with openpyxl import blocked
mkdir -p "$TMP/block" && echo 'raise ImportError("blocked")' > "$TMP/block/openpyxl.py"
if PYTHONPATH="$TMP/block" python3 "$SK/scripts/build_workbook.py" "$TMP/s.json" "$TMP/fb.xlsx" >/dev/null 2>&1 && [ -s "$TMP/fb/Summary.csv" ] && [ -s "$TMP/fb/Language.csv" ] && [ -s "$TMP/fb/Quotes.csv" ]; then report 14d 1 ""; else report 14d 0 "CSV fallback missing Summary, Language or Quotes"; fi
rm -rf "$TMP"

# 15. Agent rules
chk 15a "$TARGET/agents/source-researcher.md" "Do not spawn other agents" "no nested agents rule"
chk 15b "$TARGET/agents/source-researcher.md" "Verbatim only" "verbatim rule"
chk 15c "$TARGET/agents/source-researcher.md" "under 100 words" "output cap"

# 15b. Verification and audience-fit stage
chk 15d "$SK/SKILL.md" "Step 5b" "SKILL.md must have the verify-and-fit step before synthesis"
chk 15e "$SK/SKILL.md" "quote-verifier" "SKILL.md must spawn quote-verifier"
chk 15f "$SK/SKILL.md" "audience-fit-reviewer" "SKILL.md must spawn audience-fit-reviewer"
chk 15g "$SK/SKILL.md" "Never silently continue on a .poor. verdict" "poor fit must stop for the user"
chk 15h "$TARGET/agents/quote-verifier.md" "Never alter, repair, or paraphrase" "verifier must never edit quotes"
chk 15i "$TARGET/agents/audience-fit-reviewer.md" "Read-only" "fit reviewer must be read-only"
chk 15j "$SK/references/source-groups.md" "source_excerpt" "findings schema must carry source_excerpt"
# verify_quotes.py behaves: one verbatim quote passes, a non-matching one and a missing excerpt fail
VT=$(mktemp -d); mkdir -p "$VT/raw"
cat > "$VT/raw/x.json" <<'JSON'
{"group":"x","findings":[
 {"quote":"It\u2019s  a giant waste","url":"https://e.com/a","source_excerpt":"foo it's a giant waste of money"},
 {"quote":"nope","url":"https://e.com/b","source_excerpt":"something else"},
 {"quote":"q","url":"https://e.com/c"}]}
JSON
OUT=$(python3 "$SK/scripts/verify_quotes.py" "$VT" 2>&1)
if [ "$OUT" = "excerpt-checked 1, unverified 2" ]; then report 15k 1 ""; else report 15k 0 "verify_quotes.py gave: $OUT"; fi
rm -rf "$VT"

# 16. Built-artifact structure (only when scanning an unzipped build)
if [ ! -d "$TARGET/.git" ] && [ -f "$TARGET/.claude-plugin/plugin.json" ]; then
  BAD=$(find "$TARGET" \( -name '.git' -o -name '.DS_Store' -o -name '__pycache__' -o -name '*.plugin' -o -name 'test-*' \) 2>/dev/null | head -3)
  if [ -z "$BAD" ]; then report 16 1 ""; else report 16 0 "build carries: $BAD"; fi
fi

echo ""
echo "RESULT: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
