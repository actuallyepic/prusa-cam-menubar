#!/usr/bin/env bash
set -euo pipefail

APP_NAME="PrusaCam"
DEFAULT_INSTALL_DIR="/Applications"
USER_INSTALL_DIR="$HOME/Applications"

INSTALL_DIR="${1:-$DEFAULT_INSTALL_DIR}"
APP_PATH="$INSTALL_DIR/$APP_NAME.app"

if [[ ! -d "$APP_PATH" && "$INSTALL_DIR" == "$DEFAULT_INSTALL_DIR" ]]; then
  INSTALL_DIR="$USER_INSTALL_DIR"
  APP_PATH="$INSTALL_DIR/$APP_NAME.app"
fi

if [[ ! -d "$APP_PATH" ]]; then
  echo "Not installed: $APP_PATH"
  exit 0
fi

rm -rf "$APP_PATH"
echo "Removed: $APP_PATH"

