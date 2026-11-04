#!/usr/bin/env python3
"""Build the pain-point workbook from synthesis.json.

Usage: build_workbook.py <synthesis.json> <output.xlsx>
Falls back to one CSV per sheet if openpyxl is not installed.
"""
import csv
import json
import sys
from pathlib import Path

SHEETS = [
    ("Top 10", "top10", ["rank", "pain_point", "category", "frequency", "intensity", "summary"]),
    ("Categories", "categories", ["category", "frequency", "frequency_share", "intensity",
                                   "business_impact", "impact_reason", "opportunity_score"]),
    ("Category Detail", "category_detail", ["category", "behavioral_patterns", "emotional_triggers",
                                             "competitor_mentions", "opportunity_score", "opportunity_rationale"]),
    ("Quotes", "quotes", ["id", "category", "quote", "url", "platform", "date", "competitor",
                          "emotion", "intensity"]),
    ("Hidden Insights", "hidden_insights", ["insight", "evidence", "quote_ids"]),
    ("Competitor Gaps", "competitor_gaps", ["competitor", "pain_category", "how_they_fail",
                                             "evidence_quote_ids"]),
    ("Action Matrix", "action_matrix", ["category", "quadrant", "action", "next_step", "effort",
                                         "opportunity_score", "evidence_quote_ids"]),
    ("Sources", "sources", ["type", "name", "url", "platform", "cited_in"]),
]

LANG_VOCAB = ["term", "type", "sources", "note"]
LANG_EMO = ["emotion", "share_pct"]


def summary_rows(meta):
    rows = [
        ("Audience", meta.get("audience", "")),
        ("Category", meta.get("category", "")),
        ("Own product", meta.get("own_product", "")),
        ("Date", meta.get("date", "")),
        ("Competitors", ", ".join(meta.get("competitors", []))),
    ]
    for lim in meta.get("limitations", []):
        rows.append(("Limitation", lim))
    return rows


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    src, out = Path(sys.argv[1]), Path(sys.argv[2])
    data = json.loads(src.read_text(encoding="utf-8"))

    try:
        from openpyxl import Workbook
        from openpyxl.styles import Alignment, Font, PatternFill
        from openpyxl.utils import get_column_letter
    except ImportError:
        csv_dir = out.with_suffix("")
        csv_dir.mkdir(exist_ok=True)
        for name, key, cols in SHEETS:
            with open(csv_dir / f"{name}.csv", "w", newline="", encoding="utf-8") as f:
                w = csv.writer(f)
                w.writerow(cols)
                for r in data.get(key, []):
                    w.writerow([r.get(c, "") for c in cols])
        with open(csv_dir / "Summary.csv", "w", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            w.writerow(["Field", "Value"])
            w.writerows(summary_rows(data.get("meta", {})))
        lang = data.get("language", {})
        with open(csv_dir / "Language.csv", "w", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            w.writerow(LANG_VOCAB)
            for r in lang.get("vocabulary", []):
                w.writerow([r.get(c, "") for c in LANG_VOCAB])
            w.writerow([])
            w.writerow(LANG_EMO)
            for r in lang.get("emotions", []):
                w.writerow([r.get(c, "") for c in LANG_EMO])
            if lang.get("method_note"):
                w.writerow([])
                w.writerow(["Method", lang["method_note"]])
        print(f"openpyxl missing; wrote CSVs to {csv_dir}")
        return

    wb = Workbook()
    head_fill = PatternFill("solid", fgColor="1F2937")
    head_font = Font(bold=True, color="FFFFFF")

    def style(ws, ncols):
        for c in ws[1]:
            c.fill, c.font = head_fill, head_font
        ws.freeze_panes = "A2"
        for i in range(1, ncols + 1):
            ws.column_dimensions[get_column_letter(i)].width = 28
        for row in ws.iter_rows(min_row=2):
            for c in row:
                c.alignment = Alignment(wrap_text=True, vertical="top")
        if ws.max_row > 1:
            ws.auto_filter.ref = ws.dimensions

    ws = wb.active
    ws.title = "Summary"
    ws.append(["Field", "Value"])
    for r in summary_rows(data.get("meta", {})):
        ws.append(list(r))
    style(ws, 2)
    ws.column_dimensions["B"].width = 90

    for name, key, cols in SHEETS:
        ws = wb.create_sheet(name)
        ws.append(cols)
        for r in data.get(key, []):
            ws.append([r.get(c, "") for c in cols])
        style(ws, len(cols))
        if name == "Quotes":
            ws.column_dimensions["C"].width = 80
            ws.column_dimensions["D"].width = 50
            for row in ws.iter_rows(min_row=2, min_col=4, max_col=4):
                for c in row:
                    if isinstance(c.value, str) and c.value.startswith("http"):
                        c.hyperlink = c.value
        if name == "Sources":
            ws.column_dimensions["C"].width = 60
            for row in ws.iter_rows(min_row=2, min_col=3, max_col=3):
                for c in row:
                    if isinstance(c.value, str) and c.value.startswith("http"):
                        c.hyperlink = c.value

    lang = data.get("language", {})
    ws = wb.create_sheet("Language")
    ws.append(LANG_VOCAB)
    for r in lang.get("vocabulary", []):
        ws.append([r.get(c, "") for c in LANG_VOCAB])
    ws.append([])
    ws.append(LANG_EMO)
    for r in lang.get("emotions", []):
        ws.append([r.get(c, "") for c in LANG_EMO])
    if lang.get("method_note"):
        ws.append([])
        ws.append(["Method", lang["method_note"]])
    style(ws, 4)

    wb.save(out)
    print(f"wrote {out}")


if __name__ == "__main__":
    main()
