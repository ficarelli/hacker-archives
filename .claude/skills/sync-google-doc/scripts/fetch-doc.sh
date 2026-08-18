#!/usr/bin/env bash
# Fetch every tab of a publicly-shared Google Doc as structured plain text.
#
# FALLBACK PATH. Prefer the Google Drive MCP connector (see SKILL.md) when it is
# available: it authenticates as the user, returns every tab in one call, and can
# include comments, which this script cannot see. Use this when there is no
# connector - headless or cron runs - or when the connector's output looks
# truncated or its tab boundaries are ambiguous.
#
# Usage: fetch-doc.sh [OUT_DIR] [DOC_ID_OR_URL]
#
#   OUT_DIR         where to write the fetched files (default: a fresh mktemp dir)
#   DOC_ID_OR_URL   document id, or any docs.google.com URL containing one
#                   (default: the Hacker Archives source doc)
#
# Writes into OUT_DIR:
#   FETCHED             doc id + fetch timestamp
#   edit.html           raw editor page (source of the tab list)
#   tabs.tsv            position <TAB> tab_id <TAB> title <TAB> slug
#   NN-<slug>.html      raw per-tab HTML export
#   NN-<slug>.txt       per-tab text: "### Heading", "- item", "text @@url@@"
#
# Requires: curl, perl. The doc must be link-shared ("anyone with the link");
# private docs make the export endpoint return an error and this exits non-zero.

set -euo pipefail

DEFAULT_DOC="1HK55hKECKDxbm7sqb5qPFrUM5Qu5bP7ytWv1jNfLSnk"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OUT_DIR="${1:-}"
DOC_INPUT="${2:-$DEFAULT_DOC}"

if [ -z "$OUT_DIR" ]; then
  OUT_DIR="$(mktemp -d -t gdoc-sync-XXXXXX)"
fi
mkdir -p "$OUT_DIR"

# Accept a full URL or a bare id.
case "$DOC_INPUT" in
  *docs.google.com*)
    DOC_ID="$(printf '%s' "$DOC_INPUT" | sed -n 's|.*/document/d/\([^/?#]*\).*|\1|p')"
    ;;
  *)
    DOC_ID="$DOC_INPUT"
    ;;
esac

if [ -z "$DOC_ID" ]; then
  echo "fetch-doc.sh: could not determine a document id from '$DOC_INPUT'" >&2
  exit 1
fi

BASE="https://docs.google.com/document/d/$DOC_ID"
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"

fetch() { # fetch URL DEST
  curl -fsSL --retry 2 --retry-delay 2 --max-time 90 -A "$UA" "$1" -o "$2"
}

echo "doc_id=$DOC_ID" > "$OUT_DIR/FETCHED"
echo "fetched_at=$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$OUT_DIR/FETCHED"

# 1. Tab list, from the editor page.
if ! fetch "$BASE/edit" "$OUT_DIR/edit.html"; then
  echo "fetch-doc.sh: could not fetch $BASE/edit - is the doc link-shared?" >&2
  exit 1
fi
perl "$SCRIPT_DIR/parse-tabs.pl" < "$OUT_DIR/edit.html" > "$OUT_DIR/tabs.tsv"

# 2. Each tab's content, from the HTML export (keeps hyperlinks).
n=0
while IFS=$'\t' read -r pos id title slug; do
  [ -n "${id:-}" ] || continue
  idx="$(printf '%02d' "$n")"
  html="$OUT_DIR/$idx-$slug.html"
  txt="$OUT_DIR/$idx-$slug.txt"
  if ! fetch "$BASE/export?format=html&tab=$id" "$html"; then
    echo "fetch-doc.sh: failed to export tab $id ($title)" >&2
    exit 1
  fi
  perl "$SCRIPT_DIR/html-to-text.pl" < "$html" > "$txt"
  printf '%s\t%s\t%s\t%s\n' "$idx" "$id" "$title" "$txt"
  n=$((n + 1))
done < "$OUT_DIR/tabs.tsv"

echo
echo "Fetched $n tab(s) into $OUT_DIR"
