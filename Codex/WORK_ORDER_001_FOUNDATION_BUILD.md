# WO-001 — Foundation Build and Repository Normalization

## Objective

Turn the supplied baseline into a clean, reproducible repository that builds on both iOS Simulator and macOS before any new feature work begins.

## Scope

1. Inspect the `.xcodeproj`, source membership, deployment targets, entitlements, Info.plist, and schemes.
2. Remove dead or duplicate source files and resolve naming collisions.
3. Fix all compiler errors on iOS Simulator and macOS.
4. Rename project-facing identifiers consistently from legacy `RFVisionPro` to `RFVisionEnterprise` where safe:
   - Project name
   - Target name
   - Product/display name
   - Shared scheme
   - Source root folder if practical
   Do not change the bundle identifier without documenting it.
5. Ensure platform-specific APIs compile conditionally.
6. Add or update a shared scheme suitable for command-line builds.
7. Add a minimal unit-test target if absent, with at least one deterministic smoke test.
8. Update `README.md` with verified build commands.
9. Run both platform builds and tests.
10. Write `Codex/LAST_RUN_REPORT.md`.

## Acceptance criteria

- iOS Simulator build succeeds using an available simulator SDK/destination.
- macOS build succeeds without requiring an iOS device.
- Unit tests pass on at least one supported destination.
- No duplicate `IPAddressReader` implementation remains.
- Repository contains no credentials or generated build artifacts.
- A clean Git commit exists with a descriptive message.

## Suggested commands

Discover schemes and destinations first:

```bash
xcodebuild -list -project RFVisionPro.xcodeproj
xcodebuild -showdestinations -project RFVisionPro.xcodeproj -scheme RFVisionPro
```

Use actual discovered scheme/project names after renaming. Do not hard-code a simulator model that is unavailable.
