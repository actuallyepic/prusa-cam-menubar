#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_LABEL="3.7.0"
ARCHIVE_URL="https://download.videolan.org/pub/cocoapods/prod/VLCKit-3.7.0-591b8996-f9020c4d.tar.xz"

DOWNLOAD_DIR="$ROOT_DIR/Vendor/downloads"
OUT_DIR="$ROOT_DIR/Vendor/VLCKit"
ARCHIVE_PATH="$DOWNLOAD_DIR/VLCKit-${VERSION_LABEL}.tar.xz"

mkdir -p "$DOWNLOAD_DIR"

echo "Downloading VLCKit (${VERSION_LABEL})..."
curl -L -o "$ARCHIVE_PATH" "$ARCHIVE_URL"

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

echo "Extracting VLCKit.xcframework..."
tar -xf "$ARCHIVE_PATH" -C "$OUT_DIR" --strip-components=1 \
	"VLCKit - binary package/VLCKit.xcframework" \
	"VLCKit - binary package/COPYING.txt" \
	"VLCKit - binary package/NEWS.txt"

echo "Done: $OUT_DIR/VLCKit.xcframework"

