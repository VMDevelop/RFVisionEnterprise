#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PROJECT="RFVisionPro.xcodeproj"
SCHEME="RFVisionPro"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "xcodebuild not found. Run this script on macOS with Xcode installed." >&2
  exit 1
fi

xcodebuild -version
xcodebuild -list -project "$PROJECT"

echo "Codex must discover an available iOS Simulator destination before running the iOS build."
echo "Example macOS build:"
echo "xcodebuild -project '$PROJECT' -scheme '$SCHEME' -configuration Debug -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build"
