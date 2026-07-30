#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PROJECT="RFVisionEnterprise.xcodeproj"
SCHEME="RFVisionEnterprise"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "xcodebuild not found. Run this script on macOS with Xcode installed." >&2
  exit 1
fi

xcodebuild -version
xcodebuild -list -project "$PROJECT"

xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration Debug \
  -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration Debug \
  -destination "platform=macOS" CODE_SIGNING_ALLOWED=NO build
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration Debug \
  -destination "platform=macOS" CODE_SIGNING_ALLOWED=NO test
