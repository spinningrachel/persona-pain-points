# synthesis.json schema and workbook layout

`scripts/build_workbook.py` reads `synthesis.json` and writes one sheet per top-level key below. Missing keys produce an empty sheet.

```json
{
  "meta": {
    "audience": "", "category": "", "own_product": "", "date": "YYYY-MM-DD",
    "competitors": [""], "limitations": [""]
  },
  "top10": [
    {"rank": 1, "pain_point": "", "category": "", "frequency": 0, "intensity": 0.0, "summary": ""}
  ],
  "categories": [
    {"category": "", "frequency": 0, "frequency_share": "0%", "intensity": 0.0,
     "business_impact": "High|Medium|Low", "impact_reason": "", "opportunity_score": 0}
  ],
  "category_detail": [
    {"category": "", "behavioral_patterns": "", "emotional_triggers": "",
     "competitor_mentions": "", "opportunity_score": 0, "opportunity_rationale": ""}
  ],
  "quotes": [
    {"id": "Q001", "category": "", "quote": "", "url": "", "platform": "", "date": "",
     "competitor": "", "emotion": "", "intensity": 0, "speaker_role": "target|adjacent|vendor_or_consultant|learner|unknown", "verification": "verified|excerpt-checked"}
  ],
  "hidden_insights": [{"insight": "", "evidence": "", "quote_ids": "Q001, Q014"}],
  "competitor_gaps": [
    {"competitor": "", "pain_category": "", "how_they_fail": "", "evidence_quote_ids": ""}
  ],
  "language": {
    "vocabulary": [{"term": "", "type": "word|phrase|metaphor|device", "sources": 0, "note": ""}],
    "emotions": [{"emotion": "", "share_pct": 0}],
    "method_note": ""
  },
  "action_matrix": [
    {"category": "", "quadrant": "quick_win|strategic|monitor|ignore", "action": "",
     "next_step": "", "effort": "Low|Medium|High", "opportunity_score": 0, "evidence_quote_ids": ""}
  ],
  "audience_fit": [
    {"metric": "verdict|role share|regime coverage|competitor coverage|source mix|date spread|re-run suggestion", "value": "", "note": "sample size or detail"}
  ],
  "sources": [
    {"type": "community|forum|review|post|thread|video", "name": "", "url": "", "platform": "", "cited_in": "Q001"}
  ]
}
```

## Sheets

`Summary`, `Audience Fit`, `Top 10`, `Categories`, `Category Detail`, `Quotes`, `Hidden Insights`, `Competitor Gaps`, `Action Matrix`, `Sources`, `Language`.

`Quotes` and `Sources` are the sheets for filtering and pivoting after the run. Keep `id` values stable (`Q001`...) so other sheets can cite them.
