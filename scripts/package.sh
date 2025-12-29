#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="PrusaCam"

"$ROOT_DIR/scripts/build.sh"

SRC_APP="$ROOT_DIR/build/$APP_NAME.app"
if [[ ! -d "$SRC_APP" ]]; then
  echo "Missing app bundle at: $SRC_APP" >&2
  exit 1
fi

DIST_DIR="$ROOT_DIR/dist"
mkdir -p "$DIST_DIR"

DEST_APP="$DIST_DIR/$APP_NAME.app"
if [[ -d "$DEST_APP" ]]; then
  rm -rf "$DEST_APP"
fi

/usr/bin/ditto "$SRC_APP" "$DEST_APP"

ZIP_PATH="$DIST_DIR/$APP_NAME.zip"
rm -f "$ZIP_PATH"
(cd "$DIST_DIR" && /usr/bin/zip -r -q "$APP_NAME.zip" "$APP_NAME.app")

echo "Packaged: $ZIP_PATH"

