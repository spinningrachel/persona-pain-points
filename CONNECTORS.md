# Connectors

## Plugin path convention

Skills and agents reference plugin files with `${CLAUDE_PLUGIN_ROOT}`, never an absolute path. The variable resolves to the install root in Claude Code and in Cowork, so paths survive reinstalls and moves.

- Workbook builder: `${CLAUDE_PLUGIN_ROOT}/skills/pain-point-research/scripts/build_workbook.py`
- References: `${CLAUDE_PLUGIN_ROOT}/skills/pain-point-research/references/`

## Connectors for this plugin

None are bundled. The plugin uses whatever the user has installed and checks at the start of each run.

| Category | Needed? | Examples | If missing |
|---|---|---|---|
| Web search and fetch | Required | Built-in WebSearch/WebFetch | Run cannot collect evidence |
| Competitive intelligence source | Required | Notion, Drive, local file, URL, pasted text | Run waits for it |
| LinkedIn | Optional | A LinkedIn MCP server (read/search tools only) | Falls back to scrapers, then public web |
| Reddit | Optional | A Reddit MCP server | Falls back to scrapers, then `site:reddit.com` |
| Scrapers | Optional | Apify, HasData, Nimble, Exa, similar | Agents try these before giving up on LinkedIn or Reddit |
| Python 3 + `openpyxl` | Optional | `pip install openpyxl` | Workbook falls back to one CSV per sheet |

Write tools for LinkedIn (send message, connect) are never called.

## Review sites

G2, Capterra, TrustRadius and Gartner are not scraped around when they block fetching. The gap is reported; the user may supply exported reviews or approve a specific scraper.

## Cowork notes

- Connectors differ between Cowork and Code. The run lists what is reachable at the start and records every skipped source in the report's Limitations.
- Cowork sessions may be sandboxed. Output goes to the selected working folder. If it is not writable, the skill asks for another folder instead of writing elsewhere.
- If Python or `openpyxl` is unavailable in the sandbox, the CSV fallback keeps all tables.
