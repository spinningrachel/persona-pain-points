# CLAUDE.md

Working rules for anyone (human or Claude) changing the persona-pain-points plugin.

## Mandatory final runs

Every change ends with these, in order. A change is not done until all pass.

1. `python3 scripts/check-frontmatter.py .` - installer rejects the whole plugin on one invalid YAML frontmatter block.
2. `bash scripts/qa-mechanical.sh .` - mechanical battery on the source.
3. `bash scripts/build-plugin.sh` - builds `persona-pain-points.plugin` for Cowork and Desktop upload, then unzips it and runs the same battery on the artifact.
4. Spawn the `qa-plugin` agent (Opus) for the semantic pass: trace a run, contradiction hunt, read-only and privacy rules, Cowork readiness. Fix every FAIL, then rerun 1-3.
5. Commit the rebuilt `persona-pain-points.plugin` with the source change, with the version bumped in `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` (they must match) and a changelog entry in `README.md`.

The pre-commit hook (`git config core.hooksPath .githooks`) runs steps 1-2 on every commit. It does not replace steps 3-4.

## Prepare for Cowork, not only Code

Every release is prepared for both. Before shipping, confirm:

- The `.plugin` has `.claude-plugin/plugin.json` at its zip root.
- Skills and agents use `${CLAUDE_PLUGIN_ROOT}`; no absolute or home-relative paths in shipped files (QA check 11).
- No hooks or shell commands that Cowork's sandbox may not run. Scripts degrade: the workbook builder falls back to CSV when Python or `openpyxl` is unavailable.
- Output goes to the working folder (Cowork: the selected folder); the skill asks for another folder if it is not writable.
- Connector differences are documented in `CONNECTORS.md`, and the run records skipped sources in Limitations.
- The README install section covers the `.plugin` upload (Cowork and Code) and the marketplace route (Code).
- State what could not be tested inside Cowork in the changelog entry.

## Rules the plugin must keep

- Intake runs on every trigger and nothing is saved between runs: exact target audience, product category, competitive intelligence link or path.
- A vague category or audience blocks the run until the user answers follow-up questions. Never fill the gap with a guessed list of frameworks.
- LinkedIn and Reddit: native connector, then scraper connectors, then public web, then give up and record it. Review sites (G2, Capterra, TrustRadius, Gartner) are never scraped around; the gap is reported.
- Read-only. No posting, messaging, connecting, commenting, or logging in to private content.
- Quotes are verbatim and tied to an exact URL, or they are dropped.

## Never ship

- Research run output (`pain-point-research/`): it holds client competitive intelligence and scraped quotes.
- Client or product names from test runs, in any shipped file.
- Test files (`test-*`): the build excludes them.

## Layout

```
.claude-plugin/   plugin.json, marketplace.json
agents/           source-researcher (collection), qa-plugin (QA)
skills/pain-point-research/   SKILL.md, references/, scripts/build_workbook.py
scripts/          qa-mechanical.sh, build-plugin.sh, check-frontmatter.py
.githooks/        pre-commit
```
