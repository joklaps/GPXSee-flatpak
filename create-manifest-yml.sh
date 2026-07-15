#!/usr/bin/env bash

set -euo pipefail

TEMPLATE="org.gpxsee.GPXSee.yml.template"
MANIFEST="org.gpxsee.GPXSee.yml"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 16.11"
    exit 1
fi

VERSION="$1"
URL="https://github.com/tumic0/GPXSee/archive/refs/tags/${VERSION}.tar.gz"

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

echo "Downloading ${URL}..."
curl -L --fail -o "$TMPFILE" "$URL"

SHA256=$(sha256sum "$TMPFILE" | awk '{print $1}')

echo "Creating manifest..."

# Start from a fresh copy every time
cp "$TEMPLATE" "$MANIFEST"

# Replace placeholders
sed -i \
    -e "s|@URL@|$URL|g" \
    -e "s|@SHA256@|$SHA256|g" \
    "$MANIFEST"

echo
echo "Manifest : $MANIFEST"
echo "Version  : $VERSION"
echo "SHA256   : $SHA256"
echo "Done."
