# Optional connectors: LinkedIn and Reddit

LinkedIn and Reddit access improves coverage but is never required. The plugin does not stop when either is missing.

## Detection

At run start, check the available tool list for:

- **LinkedIn**: tools named like `mcp__linkedin-mcp__search_posts`, `get_company_posts`, `get_feed`
- **Reddit**: tools named like `mcp__*reddit*__*` (search, get thread/comments)

A server that is listed but failing to connect counts as unavailable. Do not try to repair it mid-run.

## Fallback ladder (applies to LinkedIn and Reddit only)

Review sites (G2, Capterra, TrustRadius, Gartner) are not part of this ladder. When they return 403 or a bot check, do not route around it with scrapers; record the gap in Limitations and ask the user how to proceed (for example, supply exported reviews or approve a specific scraper).

Try each rung in order. Give up on a source only after every available rung has failed.

1. **Native connector** (LinkedIn MCP, Reddit MCP).
2. **Scraper connectors**, when the user has any installed. Detect by tool name or server: Apify (`search-actors`, `call-actor`, `get-dataset-items`), HasData (`hasdata_*`), Nimble (`nimble_*`), Exa (`web_search_exa`, `web_fetch_exa`), Firecrawl, Bright Data, or similar. Look for a scraper or actor built for the blocked source (for example a Reddit, LinkedIn posts, or YouTube comments scraper), read its input schema, and run it with small limits (a few hundred items at most).
3. **Public web search/fetch** (`site:` queries, direct page fetch).
4. **Give up on that source.** Record the reason and every rung tried in `skipped`, and in the report's Limitations.

Record which scraper was used in the findings file (`skipped` or a note) so the orchestrator can name it in the final chat reply; subagents cannot post to chat. Prefer actors with high usage and ratings. Never use a scraper to log in, bypass authentication, or reach private content.

## Behavior when connectors are unavailable

| Missing | Action |
|---|---|
| LinkedIn | Go to rung 2, then 3. Limitations note if all fail: "LinkedIn unavailable; coverage limited to what rungs 2-3 returned." |
| Reddit | Go to rung 2, then 3. Same Limitations note pattern. |
| Both | Apply both rows. Say so in the final chat reply. |

## Safety

LinkedIn tools include write actions (send message, connect). Only call read/search tools. Never send, connect, comment, or post.

## Installing connectors (for the user)

Install a LinkedIn MCP and a Reddit MCP/connector through the Claude connector settings, then restart the session. Scraper connectors (Apify, HasData, Nimble, Exa) install the same way.
