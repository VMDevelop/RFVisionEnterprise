# Architecture

## Direction

Use a modular, testable Swift architecture with a thin application target and domain-specific modules. Codex should normalize the existing project first, then migrate incrementally rather than performing an uncontrolled rewrite.

## Planned modules

```text
RFVisionEnterpriseApp
RFCore
RFNetworking
RFPersistence
RFMist
RFSurvey
RFDiagnostics
RFMacWireless
RFReporting
RFUI
```

## Layers

- **Presentation:** SwiftUI views and view models
- **Domain:** entities, use cases, validation, scoring rules
- **Data:** repositories, API clients, local persistence, Keychain
- **Platform adapters:** Network.framework, CoreLocation, CoreWLAN, camera/QR

## Concurrency

- UI-facing state is `@MainActor`.
- Network, file, image, and database work executes asynchronously.
- Cancellation must propagate through survey sampling and diagnostics.
- Avoid repeated API polling from view bodies.

## Persistence

Initial baseline may use Codable files, but the production direction is SwiftData or SQLite-backed repositories with migrations. Mist credentials belong in Keychain. Floor plans are stored as managed project assets, not inline UserDefaults data.

## Data provenance

Every RF metric records a source:

- `nativeCoreWLAN`
- `mistAPSide`
- `appleNormalized`
- `externalProbe`
- `unavailable`

The UI must display the source where interpretation matters.
