#!/bin/bash
set -e
set -x

echo "=== Starting build ==="
echo "Timestamp: $(date)"

REPO_DIR="$(pwd)"
# Must match the `version` field in rheo.toml, and it is also the floor both
# `@rookery/core` and `@rookery/search` declare. 0.6.2 is the first release that
# reads the `.marrow.typ` of a package fetched from a repository ref — the way
# `[packages.rookery]` in rheo.toml fetches them — so it is the first that mints
# the per-idea pages under `ideas/`. Under 0.6.1 that step is skipped silently
# and every search result links to a file that was never written.
RHEO_VERSION="v0.6.2"
# Keyed by version: the cache is only ever checked for existence, so a shared
# `.rheo-binary/rheo` would keep serving whatever release was downloaded first
# and a bump here would quietly do nothing on any machine that had already
# built once.
RHEO_CACHE="$REPO_DIR/.rheo-binary/$RHEO_VERSION"
RHEO_BIN="$RHEO_CACHE/rheo"

if [ ! -f "$RHEO_BIN" ]; then
  echo "Downloading rheo ${RHEO_VERSION}..."
  mkdir -p "$RHEO_CACHE"
  curl -sL "https://github.com/freecomputinglab/rheo/releases/download/${RHEO_VERSION}/rheo-x86_64-unknown-linux-gnu.zip" -o /tmp/rheo.zip
  unzip -o /tmp/rheo.zip -d "$RHEO_CACHE"
  chmod +x "$RHEO_BIN"
  rm /tmp/rheo.zip
  echo "Rheo downloaded successfully"
else
  echo "Using cached rheo binary"
fi

export PATH="$RHEO_CACHE:$PATH"
rheo --version || echo "Warning: rheo --version failed, but continuing..."

echo "Compiling with rheo..."
rheo compile .

if [ ! -f "build/html/index.html" ]; then
  echo "Error: build/html/index.html not found after compilation"
  exit 1
fi

HTML_COUNT=$(find build/html -name "*.html" | wc -l)
echo "Successfully generated $HTML_COUNT HTML files"

echo "=== Build completed successfully ==="
echo "Timestamp: $(date)"
