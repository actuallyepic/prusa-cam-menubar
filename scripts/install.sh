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

DEFAULT_INSTALL_DIR="/Applications"
USER_INSTALL_DIR="$HOME/Applications"

INSTALL_DIR="${1:-$DEFAULT_INSTALL_DIR}"
if [[ "$INSTALL_DIR" == "$DEFAULT_INSTALL_DIR" && ! -w "$DEFAULT_INSTALL_DIR" ]]; then
  INSTALL_DIR="$USER_INSTALL_DIR"
fi

mkdir -p "$INSTALL_DIR"
DEST_APP="$INSTALL_DIR/$APP_NAME.app"

if [[ -d "$DEST_APP" ]]; then
  rm -rf "$DEST_APP"
fi

/usr/bin/ditto "$SRC_APP" "$DEST_APP"

codesign --force --deep --sign - "$DEST_APP" >/dev/null 2>&1 || true
touch "$DEST_APP" || true

echo "Installed: $DEST_APP"
echo "Launch: open -a $APP_NAME"

