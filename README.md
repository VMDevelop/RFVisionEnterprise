# RF Vision Enterprise

Cross-platform SwiftUI foundation for wireless inspection, survey, diagnostics, and Mist-assisted RF visibility.

## Current status

This repository is a handoff baseline for Codex. Its first task is to validate and normalize the project using Xcode on macOS. Do not treat the current baseline as a production or TestFlight-ready build until `Codex/WORK_ORDER_001_FOUNDATION_BUILD.md` is complete.

## Quick start

Read [START_HERE.md](START_HERE.md), then initialize Git:

```bash
chmod +x Scripts/*.sh
./Scripts/bootstrap-git.sh
```

Open Codex with this repository as the workspace and submit the contents of `Codex/CODEX_START_PROMPT.md`.

## Security

Never commit real Mist credentials. `Config/MistConfig.sample.json` contains placeholders only.
