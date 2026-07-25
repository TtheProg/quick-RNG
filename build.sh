#!/usr/bin/env bash
# Builds QuickRNG.app. Pass --install to also drop it into /Applications and launch it.
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="Quick RNG"
BUNDLE="build/${APP_NAME}.app"
CONTENTS="${BUNDLE}/Contents"

echo "→ compiling (release)"
swift build -c release

echo "→ icon"
swift Scripts/make-icon.swift build/AppIcon.iconset >/dev/null
iconutil -c icns build/AppIcon.iconset -o build/AppIcon.icns

echo "→ bundling"
mkdir -p "${CONTENTS}/MacOS" "${CONTENTS}/Resources"
cp .build/release/QuickRNG "${CONTENTS}/MacOS/QuickRNG"
cp Resources/Info.plist "${CONTENTS}/Info.plist"
cp build/AppIcon.icns "${CONTENTS}/Resources/AppIcon.icns"
printf 'APPL????' > "${CONTENTS}/PkgInfo"

echo "→ signing (ad-hoc)"
codesign --force --sign - --timestamp=none "${BUNDLE}" >/dev/null 2>&1

echo "✓ ${BUNDLE}"

if [[ "${1:-}" == "--install" ]]; then
  DEST="/Applications/${APP_NAME}.app"
  echo "→ installing to ${DEST}"
  osascript -e "tell application \"${APP_NAME}\" to quit" >/dev/null 2>&1 || true
  pkill -x QuickRNG >/dev/null 2>&1 || true
  if [[ -d "${DEST}" ]]; then
    TRASH="${HOME}/.Trash/${APP_NAME} $(date +%Y%m%d-%H%M%S).app"
    mv "${DEST}" "${TRASH}"
    echo "  vorherige Version → ${TRASH}"
  fi
  ditto "${BUNDLE}" "${DEST}"
  open "${DEST}"
  echo "✓ läuft — Icon oben rechts in der Menüleiste (oder ⌥⌘R)"
fi
