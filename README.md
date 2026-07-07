# collimer-skills

A [Claude Code](https://claude.com/claude-code) plugin marketplace for **Collimer** agent skills — AI-search visibility scans and GEO tooling.

Trackers tell you you're invisible. Collimer tells you *why*, and what to fix.

## Install

```
/plugin marketplace add sandcastlelabs/collimer-skills
/plugin install collimer-scan
```

Then just ask:

> *"How visible is stripe.com in AI search?"*
> *"Run a Collimer scan on example.com and tell me the biggest gap."*

## Plugins

### `collimer-scan`
Runs a free [Collimer](https://collimer.com) AI-visibility scan against any website via the public API and reports how visible the brand is across **ChatGPT, Claude, Gemini, Perplexity, and Google AI Overviews** — a score (0–100), a confidence interval, the single biggest gap, and a branded report URL. The full report (share of voice per engine + every recommendation) unlocks with a free account.

**Prefer a raw tool?** The same scan is available as an MCP server: [`collimer-mcp`](https://github.com/sandcastlelabs/collimer-mcp) (`npx -y collimer-mcp`). The skill wraps that scan in a full interpret-and-recommend workflow; the MCP server is the bare tool.

## License

MIT © [Sandcastle Labs](https://sandcastlelabs.ai)
