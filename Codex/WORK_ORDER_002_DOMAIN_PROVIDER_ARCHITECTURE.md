# WORK ORDER 002 — Domain and Survey Provider Architecture

## Objective

Create the production domain foundation for RF Vision Enterprise so that
wireless surveys work both with and without Mist Wireless.

Mist must be an optional provider. No core project, survey session, survey
point, or measurement model may require Mist-specific identifiers or types.

## Supported Survey Modes

1. General Survey
2. Mist-Assisted Survey
3. Hybrid Survey

Survey mode controls which measurement providers are enabled, but captured
measurements must be stored in common domain models.

## Required Domain Models

Implement domain models for:

- RFProject
- FloorPlan
- SurveySession
- SurveyMode
- SurveyPoint
- NormalizedPoint
- MeasurementSource
- MeasurementKind
- MeasurementValue
- NetworkIdentity
- AccessPointIdentity
- SurveyNote
- MeasurementBatch

The models must support Codable, Sendable, Identifiable, and Equatable where
appropriate.

## Measurement Sources

Support these source identities without coupling the domain to implementation:

- localDevice
- nativeWiFi
- activeTest
- mistCloud
- imported
- externalSensor

## Measurement Kinds

At minimum model:

- rssi
- noise
- snr
- channel
- band
- phyMode
- transmitRate
- receiveRate
- latency
- jitter
- packetLoss
- dnsResolutionTime
- downloadThroughput
- uploadThroughput
- ssid
- bssid
- localIPv4
- localIPv6
- connectedAP
- roamInterruption
- vendorClientHealth

Values must retain units and measurement source.

## Provider Architecture

Create protocols for:

- SurveyMeasurementProvider
- NetworkIdentityProvider
- ActiveDiagnosticsProvider
- NativeRFProvider
- VendorWirelessProvider

Providers must expose capability information so the UI can explain which
measurements are available on the current platform.

Use async/await and Sendable-safe value types.

## Platform Rules

### iOS/iPadOS

General Survey must work without Mist and must not fabricate unavailable RF
metrics.

It may collect:

- network identity exposed by public Apple APIs
- IPv4/IPv6
- active diagnostic measurements
- BSSID transitions when available
- survey position and notes

### macOS

The architecture must allow a CoreWLAN provider to supply native RF metrics in
a later work order.

### Mist

Do not implement the production Mist API client in this work order.

Provide only a mock Mist provider proving that vendor measurements can be
attached to a generic SurveyPoint without adding Mist-specific fields to the
core models.

## Persistence

Create repository protocols:

- ProjectRepository
- SurveySessionRepository

Provide a local JSON implementation suitable for the foundation stage.

Persist domain models atomically and include a schema version.

Do not store API tokens or secrets in project JSON.

## UI Scope

Add only a minimal development screen demonstrating:

- create a General project
- create a Mist-Assisted project
- create a Hybrid project
- show enabled providers and their capabilities
- capture a mock point
- reload the point from persistence

Do not build production survey canvas, heatmap, Mist settings, or dashboards in
this work order.

## Tests

Add unit tests covering:

- all survey modes
- Codable round trips
- provider capability aggregation
- generic measurements from local and Mist mock providers
- project persistence and reload
- prevention of Mist coupling in core models
- schema version handling

## Acceptance Criteria

- iOS Simulator build passes.
- macOS arm64 build passes.
- All tests pass.
- A survey project can exist and capture points with no Mist configuration.
- The same SurveyPoint can contain both native/local and mock Mist
  measurements.
- No core domain model imports or references a Mist module.
- API tokens and secrets are not written to persisted project files.
- Exact build and test commands are recorded in Codex/LAST_RUN_REPORT.md.
- Commit only after all acceptance criteria pass.

## Out of Scope

- Real Mist API calls
- Production UI
- Floor-plan canvas
- Heatmap rendering
- CoreWLAN implementation
- TestFlight
- Cisco or Aruba integrations
