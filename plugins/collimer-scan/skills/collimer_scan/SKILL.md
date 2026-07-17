---
name: collimer_scan
description: Run a Collimer free AI-visibility scan on a website and report how visible the brand is across AI search engines (ChatGPT, Claude, Gemini, Perplexity, Google AI Overviews). Use when the user asks how visible their brand or a competitor's brand/site is in AI search / LLMs / "AI answers", asks to "scan" a domain for AI visibility, or wants an AI-search visibility score for a URL. Returns a score, confidence interval, the single biggest gap, and a branded report link.
license: MIT
---

# collimer_scan — Collimer AI-visibility scan

> Runs a real Collimer free scan against a website via the public API and hands back a **teaser**: an AI-search-visibility score, its confidence interval, the top gap, and a branded report URL. The full ranked fix plan and verification re-scan live on the web behind a free account — surface the link, never fabricate it.

## When to use
- "How visible is `acme.com` in AI search / ChatGPT / Perplexity / AI answers?"
- "Run a Collimer scan / AI-visibility scan on `<domain>`."
- "What's `<brand>`'s AI search visibility score?" (their own site or a competitor's)

## How to run it
The scan is one command. Pass a bare domain or full URL; email is optional (it just lets Collimer send the results + speeds account claim later):

```bash
scripts/free_scan.sh <domain-or-url> [email]
# e.g.  scripts/free_scan.sh acme.com
#       scripts/free_scan.sh https://acme.com you@acme.com
```

It POSTs to `https://app.collimer.com/api/v1/scan`, polls until the scan completes (~30–90s), and prints the **teaser JSON** to stdout. Requires `curl` + `jq`. It tags the scan `source=agent` so it's attributable in Collimer's funnel (the MCP-server variant uses `source=mcp`).

## What you get back (the teaser)
```json
{
  "score": 15,
  "confidence_interval": { "lower": 35, "upper": 47, "plus_minus": 6 },
  "top_gap": {
    "title": "No G2 listing link detected",
    "impact": { "affects": ["Comparison", "Decision"], "estimate": "...", "timeframe": "~4 weeks" }
  },
  "brand": "Acme",
  "report_url": "https://app.collimer.com/scan/<token>",
  "cta_url": "https://app.collimer.com/users/register?scan=<token>",
  "cta_text": "Showing the top findings. Create a free account to unlock the full ranked fix plan...",
  "full_report": { "locked": true, "recommendations_total": 9, "unlock_url": "..." }
}
```
- `confidence_interval` may be `null` for some result types (e.g. CRO/flat scores) — don't assume it's always present.
- `top_gap` may be `null`. When present, `top_gap.impact` is a structured object (which funnel stages it `affects`, an `estimate`, a `timeframe`) — summarize it briefly; don't dump the raw object.

## How to present it to the user
1. Lead with the **score out of 100** and the ± confidence: e.g. *"Acme scores **41/100** (±6) for AI-search visibility."*
2. Give the **one top gap** (`top_gap.title`, with its `impact`) as the single most useful takeaway.
3. Link the **`report_url`** for the full visual breakdown, and mention the full ranked fix plan and verification re-scan unlock with a **free account** (`cta_url`).
4. Offer the **re-scan loop**: *"After you make changes, re-run the scan to measure the delta."* This is how a check turns into a shipped, verified fix.

## Hard rules
- **Never invent the full report.** You only have the teaser. Do not fabricate share-of-voice, per-engine rankings, or a full recommendation list — point to `report_url` / `cta_url` for those.
- Report the score and gap **exactly** as returned; don't editorialize the numbers.
- If the script prints an error JSON (e.g. `invalid_url`, `scan_disabled`, timeout), relay it plainly and suggest retrying — don't pretend a scan ran.

## Notes
- Public, no-auth API with built-in budget caps + rate limits; a recent scan of the same domain returns a cached result fast.
- Override the endpoint for local/staging with `COLLIMER_API_BASE`.
