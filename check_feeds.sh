#!/usr/bin/env bash
# check_feeds.sh - Probe each newsboat feed URL and classify it as OK or DEAD.
#
# Usage:   check_feeds.sh [urls_file]
# Default urls_file: ~/.newsboat/urls
# Output (one line per URL, tab-separated):  <http_code>\t<verdict>\t<url>
#   OK      -> reachable (2xx/3xx) and body looks like RSS/Atom/RDF XML
#   NOTFEED -> reachable but body is not XML (e.g. HTML error/login page)
#   DEAD    -> unreachable (DNS/timeout) or 4xx/5xx after retries
#
# Notes:
#  * Uses a browser User-Agent because some hosts (e.g. Reddit) reject the
#    default curl UA.
#  * Retries on transient failures (000/429/5xx) with exponential backoff so
#    that rate-limiting (HTTP 429) does not produce false "DEAD" results.

UA="Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0"
URLS_FILE="${1:-$HOME/.newsboat/urls}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-4}"   # total tries per URL before giving up
PARALLEL="${PARALLEL:-6}"           # concurrent probes (kept low to avoid 429s)

check_url() {
  url="$1"
  tmp="$(mktemp)"
  code="000"

  attempt=1
  while [ "$attempt" -le "$MAX_ATTEMPTS" ]; do
    code="$(curl -sSL --max-time 30 --connect-timeout 15 \
              -A "$UA" -o "$tmp" -w '%{http_code}' "$url" 2>/dev/null)"

    # Retry only on transient conditions: connection failure, rate limit, 5xx.
    case "$code" in
      000|429|5??)
        if [ "$attempt" -lt "$MAX_ATTEMPTS" ]; then
          # Exponential backoff with jitter: ~3s, 6s, 12s (+0-2s).
          sleep "$(( (1 << (attempt - 1)) * 3 + RANDOM % 3 ))"
          attempt=$(( attempt + 1 ))
          continue
        fi
        ;;
    esac
    break
  done

  verdict="DEAD"
  if [ "$code" = "000" ]; then
    verdict="DEAD"            # connection failed / timeout / DNS
  elif [ "$code" -ge 400 ] 2>/dev/null; then
    verdict="DEAD"            # 4xx/5xx
  elif [ "$code" -ge 200 ] 2>/dev/null && [ "$code" -lt 400 ] 2>/dev/null; then
    if head -c 4000 "$tmp" | grep -qiE '<rss|<feed|<rdf|<\?xml'; then
      verdict="OK"
    else
      verdict="NOTFEED"      # 2xx but body is not XML/RSS (e.g. HTML page)
    fi
  fi

  printf '%s\t%s\t%s\n' "$code" "$verdict" "$url"
  rm -f "$tmp"
}
export -f check_url
export UA MAX_ATTEMPTS

if [ ! -r "$URLS_FILE" ]; then
  echo "check_feeds.sh: cannot read urls file: $URLS_FILE" >&2
  exit 1
fi

# Extract the first whitespace-delimited field (the URL) from each non-empty,
# non-comment line, then probe with limited parallelism.
grep -vE '^[[:space:]]*($|#)' "$URLS_FILE" \
  | awk '{print $1}' \
  | xargs -P "$PARALLEL" -I {} bash -c 'check_url "$@"' _ {}
