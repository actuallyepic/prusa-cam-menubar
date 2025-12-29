#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="PrusaCam"
SRC_DIR="$ROOT_DIR/$APP_NAME/Sources"
RES_DIR="$ROOT_DIR/$APP_NAME/Resources"
VLCKIT_DIR="$ROOT_DIR/Vendor/VLCKit/VLCKit.xcframework/macos-arm64_x86_64"
BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"

mkdir -p "$CONTENTS_DIR/MacOS" "$CONTENTS_DIR/Resources" "$CONTENTS_DIR/Frameworks"

SDK_PATH="$(xcrun --sdk macosx --show-sdk-path)"
ARCH="$(uname -m)"
TARGET="${ARCH}-apple-macos13.0"

if [[ ! -d "$VLCKIT_DIR/VLCKit.framework" ]]; then
	echo "VLCKit not found. Downloading..." >&2
	"$ROOT_DIR/scripts/fetch_vlckit.sh"

	if [[ ! -d "$VLCKIT_DIR/VLCKit.framework" ]]; then
		echo "Missing VLCKit framework at: $VLCKIT_DIR/VLCKit.framework" >&2
		exit 1
	fi
fi

SWIFT_FILES=()
while IFS= read -r -d '' f; do SWIFT_FILES+=("$f"); done < <(find "$SRC_DIR" -name '*.swift' -print0)

echo "Building ${APP_NAME}..."
swiftc \
	-O \
	-sdk "$SDK_PATH" \
	-target "$TARGET" \
	-F "$VLCKIT_DIR" \
	-framework VLCKit \
	-framework SwiftUI \
	-framework AppKit \
	-framework Foundation \
	"${SWIFT_FILES[@]}" \
	-o "$CONTENTS_DIR/MacOS/$APP_NAME"

/usr/bin/ditto "$VLCKIT_DIR/VLCKit.framework" "$CONTENTS_DIR/Frameworks/VLCKit.framework"

cp "$RES_DIR/Info.plist" "$CONTENTS_DIR/Info.plist"

codesign --force --deep --sign - "$APP_DIR" >/dev/null 2>&1 || true

echo "Built: $APP_DIR"
