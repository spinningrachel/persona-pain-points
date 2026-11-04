#!/usr/bin/env python3
"""Mechanical quote check for a research run.

Usage: verify_quotes.py <run-folder>
Reads <run-folder>/raw/*.json (skips verification.json and audience-fit.json) and checks, for every
finding, that the quote appears verbatim (after whitespace, case and quote/dash normalisation) inside
the finding's `source_excerpt`, the passage the collection agent saved from the fetched or scraped text.

Statuses (the caller upgrades excerpt-checked to verified only after a live re-fetch confirms it):
  excerpt-checked  quote found in source_excerpt and the URL is well formed (not yet re-fetched)
  unverified  no source_excerpt, quote not inside it, or malformed URL
Writes <run-folder>/raw/verification.json. Exit 0 always; the caller decides what to drop.
"""
import glob, json, os, re, sys

SKIP = {"verification.json", "audience-fit.json"}


def norm(s):
    s = (s or "").lower()
    s = s.replace("’", "'").replace("‘", "'").replace("“", '"').replace("”", '"')
    s = s.replace("–", "-").replace("—", "-").replace("…", "...")
    s = re.sub(r"\s+", " ", s)
    return s.strip(" \"'")


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    run = sys.argv[1]
    items, counts = [], {"excerpt-checked": 0, "unverified": 0}
    for path in sorted(glob.glob(os.path.join(run, "raw", "*.json"))):
        if os.path.basename(path) in SKIP:
            continue
        data = json.load(open(path, encoding="utf-8"))
        group = data.get("group", os.path.basename(path))
        for i, f in enumerate(data.get("findings", [])):
            quote, exc, url = norm(f.get("quote")), norm(f.get("source_excerpt")), f.get("url", "")
            ok_url = bool(re.match(r"^https?://\S+$", url))
            if quote and exc and quote in exc and ok_url:
                status, why = "excerpt-checked", ""
            elif not exc:
                status, why = "unverified", "no source_excerpt saved"
            elif not ok_url:
                status, why = "unverified", "malformed url"
            else:
                status, why = "unverified", "quote not found in source_excerpt"
            counts[status] += 1
            items.append({"group": group, "index": i, "url": url, "status": status, "reason": why})
    out = {"summary": counts, "items": items}
    json.dump(out, open(os.path.join(run, "raw", "verification.json"), "w", encoding="utf-8"), indent=1)
    print(f"excerpt-checked {counts['excerpt-checked']}, unverified {counts['unverified']}")


if __name__ == "__main__":
    main()
