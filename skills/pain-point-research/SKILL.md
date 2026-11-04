---
name: pain-point-research
description: This skill should be used when the user asks to "research pain points", "run pain point research", "find what my audience complains about", "voice of customer research", "analyze online conversations for a persona", "mine Reddit and reviews for pain points", or starts research for a new persona, business or product. Runs the full intake-then-research workflow every time, with no saved state between runs.
version: 0.2.1
model: opus
argument-hint: "[optional: audience | category]"
---

# Pain-Point Research

## Performance Notes

- Take your time to do this thoroughly
- Quality is more important than speed
- Do not skip validation steps

Research recurring pain points of one exact target audience around one product category, across public online conversations. Every run is independent: always run the intake below, even when the same audience was researched before. Never reuse earlier answers.

## Step 1: Intake (mandatory, every run)

Ask these two questions in one message and wait for the answers. The third intake item, competitive intelligence, follows in Step 2.

1. **EXACT TARGET AUDIENCE.** Include this example: "SaaS founders with teams under 50 people". Push back on vague answers ("marketers", "small businesses") and ask for role, size, and context.
2. **PRODUCT CATEGORY.** Example: "project management tools".

If arguments were supplied, treat them as pre-filled answers and confirm them in one line instead of re-asking.

**Specificity check (blocking).** Before Step 2, test whether the product category is specific enough to steer search. It is specific when it names the product type and, for regulated or certified domains, the regimes, frameworks, or jurisdictions the buyer faces (for example "ISO 27001 renewal tooling for UK accountancy firms", not "regulatory compliance"). If it is not, ask targeted follow-up questions and wait: which regulations or frameworks, which jurisdiction, which buyer trigger (customer ask, exam, audit), and which product it competes with. Never fill the gap with a guessed list. After the competitive intelligence is read (Step 2), compare it against the answers and ask again if the two disagree. Apply the same check to a vague audience.

## Step 2: Competitive intelligence (mandatory, every run)

Ask for a link or path to the competitive intelligence for this audience and category. Accept a file path, folder, URL, Notion/Drive link, or pasted text.

- Read it fully. Extract: the user's own product or business name, the competitor list, positioning claims, and known weaknesses.
- If the source cannot be opened, say so and ask for another. Do not proceed on guesses about competitors.
- If the user's own product name is absent from the material, ask for it. G2, Capterra and TrustRadius searches need it.

## Step 3: Source availability check

Check which optional connectors are reachable (details in `references/connectors.md`):

| Source | Check | If missing |
|---|---|---|
| LinkedIn | a LinkedIn MCP/connector tool is present | Try scraper connectors (Apify, HasData, Nimble, Exa, similar), then public web search |
| Reddit | a Reddit MCP/connector tool is present | Try scraper connectors, then web search of reddit.com threads |
| Scrapers | any scraper connector installed | Note which; agents use them before giving up on LinkedIn or Reddit. Not used to get around blocks on review sites |

Follow the fallback ladder in `references/connectors.md`. Give up on a source only after every available rung fails. Never stop the run for a missing connector. Record every skipped or degraded source and the rungs tried in the report's Limitations section.

## Step 4: Create the run folder

Create `pain-point-research/<slug>-<YYYY-MM-DD>/` in the working directory (in Cowork, the selected folder), with a `raw/` subfolder. If the folder is not writable, ask for another one. Use absolute paths when briefing agents. `<slug>` is the audience plus category in kebab-case, truncated to 50 characters.

## Step 5: Parallel collection

Spawn the `source-researcher` agent once per source group, all in a single message so they run concurrently. Source groups are defined in `references/source-groups.md`. Give each agent:

- the exact audience and category
- the competitor list and own product name from the competitive intelligence
- its source group and the connector availability result
- the output path `raw/<group>.json`
- the cap: findings file only, final reply under 100 words, bullet list, no preamble, no nested agents

Each agent writes verbatim quotes with working source URLs. Quotes without a URL are discarded.

## Step 5b: Verify and review fit (mandatory, before synthesis)

After all collection agents finish, spawn both in one message:

- `quote-verifier` with the run folder. It runs `scripts/verify_quotes.py`, rescues or flags unverified quotes, and spot-checks sources.
- `audience-fit-reviewer` with the run folder, the audience, the category with its regimes and jurisdictions, the competitor list, and the buying trigger. It tags speaker roles and measures coverage.

Then act on the results:

- Drop every finding listed in `raw/verification-report.json` under `drop`. In the workbook's `verification` column, write `verified` for findings listed under `confirmed` in that report and `excerpt-checked` for the rest. Take each quote's `speaker_role` from `finding_roles` in `raw/audience-fit.json`.
- If the audience-fit verdict is `partial` or `poor`, show the user the verdict, the shares, and the re-run suggestions before synthesis. Ask whether to re-run the suggested groups with refined queries, continue as is, or stop. Never silently continue on a `poor` verdict.
- Put the verdict, role shares, uncovered regimes and uncovered competitors in the report's opening section and in the `Audience Fit` sheet.

## Step 6: Synthesis

Read all `raw/*.json` files and the competitive intelligence. Produce the nine deliverables defined in `references/deliverables.md`, in the schema in `references/workbook-schema.md`. Rules:

- Use only quotes present in the raw files and not dropped by the verifier. Never invent, paraphrase into quotation marks, or repair a quote.
- Frequency is a count of distinct sources mentioning the pain, not a guess. Intensity is a 1-5 score from the emotion tagging in the raw files, with the rubric in `references/deliverables.md`.
- Target 15-20 quotes per major category. When fewer exist, report the real count and say so. Do not pad.
- Opportunity score (1-10) must be justified by the competitive intelligence (what the user's product can credibly solve).
- Business impact is an estimate. Label it as estimated and state the reasoning in one line.

## Step 7: Build and deliver

1. Write `synthesis.json` in the run folder following the schema.
2. Run `python3 ${CLAUDE_PLUGIN_ROOT}/skills/pain-point-research/scripts/build_workbook.py <run-folder>/synthesis.json <run-folder>/pain-points.xlsx`. If `openpyxl` is missing, try `pip3 install openpyxl`. If the install is blocked or fails (for example in a sandbox), the script writes one CSV per sheet, Summary and Language included; say so.
3. Write `report.md` in the run folder: executive summary, top 10 ranked pain points, hidden insights, competitor failures, linguistic findings, limitations. Link to the workbook for the tables and quotes.
4. Reply in chat with the verdict: top 3 pain points, the paths to both files, and any skipped sources. Keep it short.

## Models

Pinned in frontmatter, not chosen at run time: this skill (intake, synthesis, delivery) runs on Opus; `source-researcher` and `quote-verifier` on Sonnet; `audience-fit-reviewer` and `qa-plugin` on Opus. To change one, edit its `model:` line and rerun the QA battery.

## Rules

- Public content only. Do not log in to private groups, scrape private profiles, or post anything. Facebook groups: use publicly visible content only; if none is reachable, say so.
- Never message, connect with, or comment on anyone on LinkedIn or Reddit.
- Keep personal identifiers out of the deliverables. Use platform handles only as they appear in the public source link, and do not compile profiles of individuals.
- Quote length: copy the relevant sentence or two, not whole posts.
- Count frequency across target and adjacent speakers first; report vendor, consultant and learner sources separately, never as practitioner evidence.

## Additional Resources

- **`references/deliverables.md`** - The nine deliverables, scoring rubrics
- **`references/source-groups.md`** - Source groups and search tactics per group
- **`references/workbook-schema.md`** - `synthesis.json` schema and sheet layout
- **`references/connectors.md`** - Optional LinkedIn and Reddit access and fallbacks
- **`references/original-prompt.md`** - The source research prompt, verbatim
- **`scripts/verify_quotes.py`** - Mechanical quote check used by `quote-verifier`
- **`scripts/build_workbook.py`** - Builds the xlsx from `synthesis.json`
