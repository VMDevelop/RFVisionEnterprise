# RF Vision Enterprise

Cross-platform SwiftUI foundation for wireless inspection, survey, diagnostics, and Mist-assisted RF visibility.

## Build and test

Use the shared `RFVisionEnterprise` scheme with signing disabled for local verification:

```bash
xcodebuild -list -project RFVisionEnterprise.xcodeproj
xcodebuild -project RFVisionEnterprise.xcodeproj -scheme RFVisionEnterprise -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project RFVisionEnterprise.xcodeproj -scheme RFVisionEnterprise -configuration Debug -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project RFVisionEnterprise.xcodeproj -scheme RFVisionEnterprise -configuration Debug -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
```

An installed iOS Simulator runtime is required for iOS asset compilation and simulator-hosted tests. See `Codex/LAST_RUN_REPORT.md` for the last verified destinations and results.

## Quick start

Read [START_HERE.md](START_HERE.md), then initialize Git:

```bash
chmod +x Scripts/*.sh
./Scripts/bootstrap-git.sh
```

Open Codex with this repository as the workspace and submit the contents of `Codex/CODEX_START_PROMPT.md`.

## Security

Never commit real Mist credentials. `Config/MistConfig.sample.json` contains placeholders only.
