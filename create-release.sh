#!/usr/bin/env bash

set -euo pipefail

APP_ID="org.gpxsee.GPXSee"
MANIFEST="${APP_ID}.yml"
REPO="repo"
DIST="dist/builds"

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: $0 <version> [platform]"
    echo
    echo "Example:"
    echo "  $0 16.11"
    echo "  $0 16.11 x86_64"
    echo "  $0 16.11 aarch64"
    exit 1
fi

VERSION="$1"
ARCH="${2:-x86_64}"

OUTPUT="${DIST}/${ARCH}/gpxsee_${ARCH}_v${VERSION}.flatpak"

mkdir -p "$DIST/$ARCH"

echo "========================================"
echo "Building GPXSee Flatpak"
echo "Version : $VERSION"
echo "Platform: $ARCH"
echo "========================================"

echo
echo "==> Building Flatpak..."
flatpak run --command=flathub-build org.flatpak.Builder \
    --force-clean \
    --arch="${ARCH}" \
    --user \
    --install-deps-from=flathub \
    --repo="${REPO}" \
    --install \
    "${MANIFEST}"

echo
echo "==> Creating bundle..."
flatpak build-bundle \
    "${REPO}" \
    "${OUTPUT}" \
    "${APP_ID}" \
    --runtime-repo=https://dl.flathub.org/repo/flathub.flatpakrepo

echo
echo "==> Verifying manifest..."
flatpak run --command=flatpak-builder-lint \
    org.flatpak.Builder \
    manifest \
    "${MANIFEST}"

echo
echo "========================================"
echo "Build completed successfully."
echo "Bundle:"
echo "  ${OUTPUT}"
echo "========================================"
