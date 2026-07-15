#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 16.11"
    exit 1
fi

VERSION="$1"
PATCH="gpxsee-appdata.patch"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# Backup existing patch
if [ -f "$PATCH" ]; then
    mv "$PATCH" "${PATCH}.${TIMESTAMP}.bak"
fi

mkdir -p dist/original-appdata

wget -O dist/original-appdata/gpxsee.appdata.xml \
    "https://raw.githubusercontent.com/tumic0/GPXSee/refs/tags/${VERSION}/pkg/linux/gpxsee.appdata.xml"

diff -u \
    --label "GPXSee-${VERSION}/pkg/linux/gpxsee.appdata.xml" \
    --label "GPXSee-${VERSION}/pkg/linux/gpxsee.appdata.xml" \
    dist/original-appdata/gpxsee.appdata.xml \
    assets/metainfo/org.gpxsee.GPXSee.metainfo.xml \
    > "$PATCH"

# Clean up
rm -rf dist/original-appdata
