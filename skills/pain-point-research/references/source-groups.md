# Source groups

Spawn one `source-researcher` agent per group. Derive the specifics (subreddits, forums, hashtags, groups) from the audience and category. Do not use a fixed list.

| Group key | Sources | Notes |
|---|---|---|
| `reddit` | 5-10 specific subreddits where the audience talks. List the chosen subreddits in the findings. | Follow the fallback ladder in `connectors.md`: Reddit connector, then scraper connectors, then web search `site:reddit.com` |
| `reviews` | G2, Capterra, TrustRadius reviews of the user's product and each competitor | Prioritize 1-3 star and "cons" sections, plus mid-rated reviews with switching stories |
| `forums-qa` | Quora topics, industry forums and communities (Hacker News, Indie Hackers, Stack Exchange, niche boards, Slack/Discord public archives) | Pick forums that match the audience, not the category generically |
| `social` | Twitter/X and LinkedIn conversations by relevant hashtags and keywords | Follow the fallback ladder in `connectors.md`: LinkedIn connector, then scraper connectors, then web search |
| `video-groups` | YouTube comments on competitor review/comparison videos; public Facebook groups where the audience gathers | Public content only; report what was unreachable |

## Search tactics for every group

- Combine audience terms with pain signal phrases: "hate", "frustrating", "alternative to", "switched from", "cancelled", "wish it could", "why is it so hard", "anyone else", "workaround".
- Search each competitor name with those phrases.
- Prefer threads with replies and agreement (upvotes, "same here") as evidence of recurrence.
- Record date and URL for every quote. Skip content older than 24 months unless it is the only evidence, and flag its age.
- Save the surrounding passage in `source_excerpt` for every finding. A finding without it cannot be verified and is dropped.
- Target 40+ quotes per group when available. Stop when new searches return no new pain themes.

## Findings file schema (`raw/<group>.json`)

```json
{
  "group": "reddit",
  "communities": [{"name": "r/example", "url": "https://..."}],
  "skipped": ["reason, if any source was unreachable"],
  "findings": [
    {
      "pain_category": "short label",
      "quote": "verbatim text",
      "url": "https://exact-thread-or-review",
      "platform": "reddit",
      "date": "YYYY-MM-DD or unknown",
      "competitor_mentioned": "name or empty",
      "competitor_handling": "how the competitor addresses or fails, if stated",
      "emotion": "frustration|anxiety|resignation|anger|confusion|hope|relief",
      "intensity": 1,
      "behavior": "workaround or action described, if any",
      "source_excerpt": "the passage as fetched or scraped, up to 600 characters, that contains the quote verbatim",
      "speaker_role": "role cue from the text, for example 'CISO', 'solo founder', 'consultant', 'vendor', or 'unknown'",
      "trigger": "what set off the emotion, if stated"
    }
  ]
}
```
