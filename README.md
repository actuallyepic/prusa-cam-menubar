# PrusaCam (menu bar RTSP viewer)

Minimal macOS menu bar app that shows a live RTSP camera stream (tested with a Prusa Core One internal camera stream).

## Features

- Lives in the macOS menu bar (no Dock icon)
- First click: popover with live stream
- Second click: fullscreen stream
- Change the RTSP URL from Settings (gear icon)
- Keeps the stream connected briefly after closing (configurable)
- Prompts to configure the RTSP URL on first run

## Requirements

- macOS 13+
- Xcode Command Line Tools (`xcrun`, `swiftc`, `codesign`)

## Setup

1) Run the app
2) Click the gear icon → Settings
3) Paste your RTSP URL and hit **Apply**

The URL is stored in `UserDefaults` and persists until you change it.

## Build

```bash
make build
```

The first build will download VLCKit (~90MB).

## Run

```bash
make run
```

## Package (zip)

```bash
make package
```

The zip will be created at `dist/PrusaCam.zip`.

## Install (so Spotlight can find it)

```bash
make install
```

Uninstall:

```bash
make uninstall
```

## VLCKit

This project downloads the VLCKit binary package into `Vendor/VLCKit` (LGPL 2.1).
To re-fetch it manually:

```bash
./scripts/fetch_vlckit.sh
```

## Troubleshooting

- **Black or blank video**: confirm the RTSP URL works in VLC, then reopen PrusaCam.
- **Still buffering**: try the Settings → Reconnect button or lower the keep‑alive timeout.
- **No URL set**: open Settings (gear icon) and paste your RTSP URL.

## License

MIT for this repo. VLCKit is LGPL 2.1 (see `Vendor/VLCKit/COPYING.txt`).

## Disclaimer

Not affiliated with Prusa Research or VideoLAN.
