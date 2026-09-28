#!/usr/bin/env bash
#
# collimer_scan — RETIRED.
#
# This script called Collimer's ANONYMOUS free-scan API. That API now requires a
# Collimer account, so every call here returns 401 and there is no version of
# this script that can succeed. Collimer is a remote MCP server instead:
#
#   claude mcp add --transport http collimer https://app.collimer.com/mcp
#
# The 401 branches below carry that guidance in the message on purpose — a bare
# "scan create failed, http_status 401" tells the caller nothing about the fix.
#
# Usage:   free_scan.sh <domain-or-url> [email]
# Example: free_scan.sh acme.com
#          free_scan.sh https://acme.com you@acme.com
#
# Prints the depth-gated TEASER as JSON on stdout when the scan completes:
#   { score, confidence_interval{lower,upper,plus_minus}|null,
#     top_gap{title,impact}|null, brand, report_url, cta_url, cta_text, ... }
#
# It NEVER returns the full report (share-of-voice + every recommendation) —
# that is gated behind a free web account; surface report_url/cta_url instead.
#
# Env overrides:
#   COLLIMER_API_BASE     (default https://app.collimer.com)
#   COLLIMER_SCAN_SOURCE  (default "agent"; the MCP server uses "mcp")
#   COLLIMER_MAX_POLLS    (default 60)   COLLIMER_POLL_INTERVAL (default 5s)
set -euo pipefail

DOMAIN="${1:-}"
EMAIL="${2:-}"
API="${COLLIMER_API_BASE:-https://app.collimer.com}"
SOURCE="${COLLIMER_SCAN_SOURCE:-agent}"
MAX_POLLS="${COLLIMER_MAX_POLLS:-60}"
POLL_INTERVAL="${COLLIMER_POLL_INTERVAL:-5}"

RETIRED_MSG='Collimer'"'"'s anonymous scan API has been retired, so this skill can no longer run a scan. Add Collimer as a remote MCP server instead: claude mcp add --transport http collimer https://app.collimer.com/mcp — your client will prompt you to sign in, and a free account is enough.'
retired() { jq -nc --arg m "$RETIRED_MSG" '{error:"retired", message:$m, remote:"https://app.collimer.com/mcp"}' >&2; exit 1; }

[ -n "$DOMAIN" ] || { echo '{"error":"usage: free_scan.sh <domain-or-url> [email]"}' >&2; exit 2; }
command -v jq   >/dev/null 2>&1 || { echo '{"error":"jq is required"}' >&2; exit 2; }
command -v curl >/dev/null 2>&1 || { echo '{"error":"curl is required"}' >&2; exit 2; }

# Normalize a bare domain ("acme.com") into an https URL.
case "$DOMAIN" in
  http://*|https://*) URL="$DOMAIN" ;;
  *)                  URL="https://$DOMAIN" ;;
esac

# Build the request body (email is optional).
if [ -n "$EMAIL" ]; then
  body="$(jq -nc --arg url "$URL" --arg email "$EMAIL" --arg source "$SOURCE" \
            '{url:$url, email:$email, source:$source}')"
else
  body="$(jq -nc --arg url "$URL" --arg source "$SOURCE" '{url:$url, source:$source}')"
fi

# 1) POST /api/v1/scan — kick off (or hit the per-domain cache).
create="$(curl -sS -X POST "$API/api/v1/scan" \
            -H 'content-type: application/json' -d "$body" -w $'\n%{http_code}')"
create_code="$(printf '%s' "$create" | tail -n1)"
create_body="$(printf '%s' "$create" | sed '$d')"

case "$create_code" in
  200|201) : ;;
  401) retired ;;
  *) printf '%s\n' "$create_body" >&2
     echo "{\"error\":\"scan create failed\",\"http_status\":${create_code}}" >&2
     exit 1 ;;
esac

token="$(printf '%s' "$create_body" | jq -r '.scan_token // empty')"
[ -n "$token" ] || { echo '{"error":"no scan_token in create response"}' >&2
                     printf '%s\n' "$create_body" >&2; exit 1; }

# 2) Poll GET /api/v1/scan/:token until complete (HTTP 200 = teaser).
i=0
while [ "$i" -lt "$MAX_POLLS" ]; do
  poll="$(curl -sS "$API/api/v1/scan/$token" -w $'\n%{http_code}')"
  poll_code="$(printf '%s' "$poll" | tail -n1)"
  poll_body="$(printf '%s' "$poll" | sed '$d')"
  case "$poll_code" in
    200) printf '%s\n' "$poll_body"; exit 0 ;;            # complete → teaser
    202) : ;;                                             # queued/running
    401) retired ;;
    404) echo '{"error":"scan token not found"}' >&2; exit 1 ;;
    *)   echo "{\"error\":\"poll failed\",\"http_status\":${poll_code}}" >&2
         printf '%s\n' "$poll_body" >&2; exit 1 ;;
  esac
  i=$((i + 1))
  sleep "$POLL_INTERVAL"
done

echo '{"error":"timed out waiting for scan to complete"}' >&2
exit 1
