# RF Vision Enterprise — Codex Operating Instructions

This file is authoritative for every Codex session in this repository.

## Mission

Build a production-grade SwiftUI application for wireless inspection, survey, diagnostics, and Mist-assisted RF visibility on iPhone, iPad, and macOS.

## Non-negotiable workflow

1. Read `START_HERE.md`, `Documents/PRODUCT_REQUIREMENTS.md`, `Documents/ARCHITECTURE.md`, and the active work order under `Codex/`.
2. Inspect the repository before editing.
3. Work on only the active work order unless a prerequisite fix is required.
4. Never claim a build or test passed without running it.
5. Before committing, build both supported platforms using `Scripts/verify-build.sh` or equivalent explicit `xcodebuild` commands.
6. Record exact commands and results in `Codex/LAST_RUN_REPORT.md`.
7. Do not commit secrets, API tokens, private configuration, provisioning profiles, or certificates.
8. Keep iOS-only and macOS-only APIs behind compile-time platform checks.
9. Prefer small, reviewable commits with descriptive messages.
10. Do not add third-party dependencies without documenting the reason and obtaining project-owner approval.

## Current baseline caveat

The current baseline was assembled outside macOS and has not been validated with Apple SDKs. Treat its build status as unknown until Codex runs Xcode builds.

## First priority

Complete `Codex/WORK_ORDER_001_FOUNDATION_BUILD.md` before adding any product features.

## Platform targets

- iOS/iPadOS 17 or later
- macOS 14 or later
- Swift 6 compatible code
- Xcode version installed on the user's Mac is the source of truth

## Quality bar

- No compile errors
- No fabricated RF values
- Platform limitations must be explicit in UI and documentation
- UI updates must occur on the main actor
- Network and persistence operations must not block the main thread
- Sensitive Mist credentials must eventually be stored in Keychain, not UserDefaults
