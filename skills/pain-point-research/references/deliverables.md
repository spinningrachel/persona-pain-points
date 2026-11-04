# Deliverables and scoring

Items 6 and 8 of the source prompt are the same Action Priority Matrix. Deliver 6 as the matrix by pain point category. Deliver 8 as the same matrix extended with owner-neutral next steps and the evidence rows backing each action. Do not duplicate content between them.

| # | Deliverable | Where it lives |
|---|---|---|
| 1 | Executive summary, top 10 pain points ranked by frequency and intensity | `report.md` + sheet `Top 10` |
| 2 | Categorization table: category, frequency, intensity, business impact | Sheet `Categories` |
| 3 | Per major category: behavioral patterns, emotional triggers, 15-20 quotes with links, competitor mentions, opportunity score 1-10 | Sheet `Category Detail` + sheet `Quotes` |
| 4 | Hidden insights | `report.md` + sheet `Hidden Insights` |
| 5 | How competitors fail these customers | `report.md` + sheet `Competitor Gaps` |
| 6 | Action priority matrix, quick wins vs strategic | Sheet `Action Matrix` |
| 7 | Linguistic devices, vocabulary, emotion estimate (commonalities across the researched persons) | Sheet `Language` + `report.md` |
| 8 | Action priority matrix, extended with next steps and evidence | Sheet `Action Matrix` columns `next_step`, `evidence_quote_ids` |
| 9 | Links to groups, forums, communities, and every cited review, post, thread | Sheet `Sources` |

## Scoring rubrics

**Frequency**: count of distinct source URLs (threads, reviews, videos) mentioning the pain. Report the count and a share of all sources reviewed. A single thread counts once however many replies repeat it.

**Intensity (1-5)**:
1. Mild annoyance, neutral tone
2. Clear frustration
3. Strong frustration, workarounds described
4. Anger, sarcasm, threats to switch
5. Churn event, public rant, loss of money or trust described

Category intensity is the mean of its quotes' intensity, rounded to one decimal.

**Business impact (estimated)**: High, Medium, or Low, with a one-line reason tied to revenue or retention (for example "named as reason for cancelling in 9 of 14 reviews"). Always labelled estimated.

**Opportunity score (1-10)**: combine (a) pain frequency and intensity, (b) how weakly competitors address it, (c) how credibly the user's product can solve it per the competitive intelligence. State the three inputs in `opportunity_rationale`.

**Priority matrix**: quick win = high opportunity score, deliverable through messaging, content, onboarding, or small product change. Strategic initiative = high score but needs product, pricing, or positioning change. Also classify low-score items as `monitor` or `ignore`.

## Language analysis (deliverable 7)

Focus on commonalities across many authors, not standout individuals. Capture:

- **Recurring vocabulary**: exact words and phrases, with counts of distinct sources
- **Metaphors and framings** (for example "death by a thousand tabs")
- **Rhetorical devices**: hyperbole, sarcasm, rhetorical questions, absolutes ("always", "never"), comparisons to competitors
- **Jargon vs plain speech**
- **Emotion estimate**: shares across frustration, anxiety, resignation, anger, confusion, hope, relief (should sum to about 100%). Label the method as an estimate from quote tagging.
