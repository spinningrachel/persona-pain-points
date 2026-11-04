# persona-pain-points

A Claude Code (and Cowork) plugin for marketers who work across multiple personas, businesses, or products and need to know what each audience actually complains about.

On every run it asks for the **exact target audience**, the **product category**, and a link or path to your **competitive intelligence**. It then sends parallel research agents through Reddit, Quora and industry forums, G2/Capterra/TrustRadius, Twitter/X and LinkedIn, YouTube comments, and public Facebook groups, and delivers ranked pain points, verbatim quotes with source links, language patterns, competitor gaps, and an action priority matrix. Nothing is saved between runs, so each persona, business, or product starts clean.

> ⚠️ **Read the Limitations section of every report.** The plugin reports what it could and could not reach. Review sites and Reddit often block automated access, a thin sample or the wrong audience skews the ranking, and intensity and emotion are model-tagged estimates. It collects evidence and drafts a ranking; you decide what to act on.

---

## Get started

**1. Install the plugin.**

[![Download persona-pain-points.plugin](https://img.shields.io/badge/⬇%20Download-persona--pain--points.plugin-2563eb?style=for-the-badge)](https://raw.githubusercontent.com/spinningrachel/persona-pain-points/main/persona-pain-points.plugin)

Open the Claude Desktop app → **Customize → Personal Plugins → +** → **Personal** (tab) → **+** → **Upload plugin**, and select the downloaded file. It becomes available in **Cowork** and **Claude Code** (not Chat).

Claude Code users can install via the marketplace instead:

```
/plugin marketplace add spinningrachel/persona-pain-points
/plugin install persona-pain-points@persona-pain-points
```

To test a local checkout in Claude Code:

```bash
claude --plugin-dir ./persona-pain-points
```

**2. Start a run.**

```
/persona-pain-points:pain-point-research
```

Or ask in plain language: "research pain points for a new persona". The plugin asks:

1. **Exact target audience.** Example: "SaaS founders with teams under 50 people". Vague answers get follow-up questions.
2. **Product category.** Example: "project management tools". For regulated or certified domains, name the regulations, jurisdictions, and the trigger that makes buyers act.
3. **Competitive intelligence.** A file path, folder, URL, Notion or Drive link, or pasted text.

**3. Read the output.**

Written to `pain-point-research/<audience-category>-<date>/` in your working folder (in Cowork, the selected folder):

| File | Contents |
|---|---|
| `pain-points.xlsx` | Sheets: Summary, Audience Fit, Top 10, Categories, Category Detail, Quotes, Hidden Insights, Competitor Gaps, Language, Action Matrix, Sources |
| `report.md` | Executive summary, hidden insights, competitor failures, language findings, limitations |
| `synthesis.json` | The structured data behind both files |
| `raw/` | Per-source findings (JSON) |

The spreadsheet holds tables, quotes, and links for filtering and pivoting. The report holds the narrative. If Python or `openpyxl` is unavailable, one CSV per sheet is written instead.

---

## Basic requirements

| Requirement | Required? | If missing |
|---|---|---|
| Web search and fetch | Yes | Run cannot collect evidence |
| Competitive intelligence | Yes | Run waits for it |
| LinkedIn connector or MCP | No | Falls back to scraper connectors, then public web; noted in Limitations |
| Reddit connector or MCP | No | Falls back to scraper connectors, then `site:reddit.com`; noted in Limitations |
| Scraper connectors (Apify, HasData, Nimble, Exa, similar) | No | Agents try these before giving up on LinkedIn or Reddit. Review sites that block fetching are reported as gaps, not scraped around |
| Python 3 and `openpyxl` | For `.xlsx` | Falls back to CSV |

The plugin skips unavailable sources and documents each one in the report. It never stops for a missing connector. Details: [CONNECTORS.md](CONNECTORS.md).

**Safety.** Read-only research of public content. It never posts, messages, connects, or comments, never logs in to private groups, and never works around a bot check.

---

## How it works

1. **Intake**, every run: audience, category, competitive intelligence, plus a specificity check that blocks vague input.
2. **Source check**: lists which connectors and scrapers are reachable.
3. **Parallel collection**: one `source-researcher` agent per source group (reddit, reviews, forums-qa, social, video-groups), each writing verbatim quotes with URLs and the source passage.
4. **Verification and fit**, before synthesis: `quote-verifier` checks every quote against its saved passage and re-fetches a sample; `audience-fit-reviewer` tags who is speaking (target, adjacent, vendor or consultant, learner) and checks coverage of the regimes and competitors in your brief. A partial or poor fit stops the run and asks you whether to re-run with refined queries.
5. **Synthesis**: nine deliverables, scored by distinct-source frequency and 1-5 intensity. Vendor, consultant and learner voices are reported separately from practitioner evidence.
6. **Delivery**: workbook and report, with skipped sources, fit verdict and sample limits stated.

Deliverables 6 and 8 of the source prompt are identical (Action Priority Matrix). The plugin delivers one matrix with the extra columns from item 8.

---

## Documentation

| Topic | File |
|---|---|
| Workflow and rules | [skills/pain-point-research/SKILL.md](skills/pain-point-research/SKILL.md) |
| The nine deliverables and scoring rubrics | [references/deliverables.md](skills/pain-point-research/references/deliverables.md) |
| Source groups and search tactics | [references/source-groups.md](skills/pain-point-research/references/source-groups.md) |
| Connector fallback ladder | [references/connectors.md](skills/pain-point-research/references/connectors.md) |
| Workbook schema | [references/workbook-schema.md](skills/pain-point-research/references/workbook-schema.md) |
| The research prompt, verbatim | [references/original-prompt.md](skills/pain-point-research/references/original-prompt.md) |
| Connectors and Cowork notes | [CONNECTORS.md](CONNECTORS.md) |
| Contributor rules and mandatory QA | [CLAUDE.md](CLAUDE.md) |

---

## Development and QA

Every change ends with mandatory QA runs and a Cowork-ready build. Full rules in [CLAUDE.md](CLAUDE.md).

```bash
git config core.hooksPath .githooks        # once: runs frontmatter + mechanical QA on every commit
python3 scripts/check-frontmatter.py .     # YAML gate
bash scripts/qa-mechanical.sh .            # mechanical battery
bash scripts/build-plugin.sh               # builds persona-pain-points.plugin and QAs the artifact
```

Then run the `qa-plugin` agent for the semantic pass before committing.

---

## Changelog

### 2026-11-04 - 0.2.0: Quote verifier and audience-fit reviewer

- New `quote-verifier` agent and `verify_quotes.py`: every finding carries the source passage; quotes not found verbatim in it are dropped, and a sample of URLs is re-fetched.
- New `audience-fit-reviewer` agent: tags speaker roles, measures coverage of the brief's regimes and competitors, and gives a good, partial or poor verdict. A partial or poor verdict stops the run for the user's decision.
- Workbook gains an `Audience Fit` sheet and `speaker_role` and `verification` columns on Quotes.
- Added in response to the first test run, where 13 of 65 Reddit quotes were never string-checked and most voices were not the stated audience.
- Not run inside Cowork from the build environment; the new stages are verified structurally and by the mechanical battery.

### 2026-11-04 - 0.1.0: First release

- Intake on every run: exact target audience (with example), product category, competitive intelligence link or path. A vague category blocks the run until the user answers follow-ups.
- Parallel `source-researcher` agents per source group; verbatim quotes tied to URLs, or dropped.
- Connector fallback ladder for LinkedIn and Reddit: native connector, scraper connectors, public web, then record the gap. Review sites are never scraped around.
- Spreadsheet plus narrative report, with CSV fallback.
- Mandatory QA (frontmatter gate, 40+ mechanical checks on source and built artifact, `qa-plugin` agent) and `.plugin` build for Cowork and Code.
- Tested end to end once in Claude Code on a compliance-software audience: 147 findings from 132 sources; Reddit data came through an Apify scraper after the connector failed; review sites returned nothing. Not run inside Cowork from the build environment, so the Cowork path is verified structurally (manifest at the zip root, no absolute paths, CSV fallback) but not by a live Cowork session.
