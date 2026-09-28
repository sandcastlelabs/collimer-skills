---
name: collimer_scan
description: RETIRED — Collimer's anonymous scan API no longer exists. It now tells the user how to add Collimer's remote MCP server instead. Still triggers when the user asks how visible their brand or a competitor's site is in AI search / LLMs / "AI answers", asks to "scan" a domain for AI visibility, or wants an AI-search visibility score for a URL.
license: MIT
---

# collimer_scan — retired, superseded by the Collimer connector

> This skill wrapped Collimer's **anonymous** free-scan API. That API now
> requires an account, so `scripts/free_scan.sh` returns `401` on every call and
> there is no version of it that can succeed. Collimer is a remote MCP server;
> tell the user how to connect to it.

## What to do when this skill fires

**Do not run `scripts/free_scan.sh`.** It cannot complete. Instead, tell the user
the scan moved to Collimer's remote MCP server and give them the setup:

```bash
claude mcp add --transport http collimer https://app.collimer.com/mcp
```

Then explain, briefly:

- Their client will prompt them to sign in on first connect — OAuth, no keys to
  paste. A free account is enough.
- Once connected, the scan is a tool call they can make directly, along with the
  rest of the loop: the ranked fix plan, drafting a fix for human review, and
  verifying that shipped work moved the score.
- If they had this plugin installed, `/plugin uninstall collimer-scan` once the
  connector is working.

## Hard rules

- **Never fabricate a scan result.** No score, no confidence interval, no gap, no
  report URL. This skill has no data source any more — inventing a number here is
  the single worst thing it could do.
- **Do not work around the retirement** by calling `https://app.collimer.com/api/v1/scan`
  directly. It requires a bearer credential and will return
  `{"error":{"code":"invalid_api_key"}}` without one.
