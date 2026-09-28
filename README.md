# collimer-skills

A [Claude Code](https://claude.com/claude-code) plugin marketplace for **Collimer** agent skills — AI-search visibility scans and GEO tooling.

Trackers tell you you're invisible. Collimer tells you *why*, and what to fix.

> ## ⚠️ `collimer-scan` is retired — use the Collimer connector
>
> The `collimer-scan` plugin shelled out to Collimer's *anonymous* scan API.
> Anonymous scans have been retired, so that script now returns `401` for
> everyone. Collimer is a **remote MCP server**, which Claude Code speaks
> natively:
>
> ```bash
> claude mcp add --transport http collimer https://app.collimer.com/mcp
> ```
>
> Your client prompts you to sign in the first time you connect — there are no
> keys to paste, and a free account is enough. The connector carries the whole
> work loop (scan, ranked fix plan, drafting for review, verification).
>
> If you have the plugin installed, `/plugin uninstall collimer-scan` after
> adding the connector.

## Plugins

### `collimer-scan` — retired

Ran a free [Collimer](https://collimer.com) AI-visibility scan against any
website via the public API and reported how visible the brand was across
**ChatGPT, Claude, Gemini, Perplexity, and Google AI Overviews**. Superseded by
the remote MCP server above, which does the same scan and everything that
follows from it.

The npm package [`collimer-mcp`](https://github.com/sandcastlelabs/collimer-mcp)
was retired at the same time and for the same reason.

## License

MIT © [Sandcastle Labs](https://sandcastlelabs.ai)
