# Product Requirements

## Product

RF Vision Enterprise is a native SwiftUI application for iPhone, iPad, and macOS that helps network engineers inspect connectivity, perform site surveys, correlate client experience with Mist Cloud RF telemetry, and produce repeatable reports.

## Core principles

- Never present inferred or unavailable radio metrics as measured facts.
- iOS and iPadOS use public Apple APIs plus authorized cloud telemetry.
- macOS may use CoreWLAN for additional native RF information.
- Survey projects must work offline after required data is cached.
- User actions and results must be traceable and exportable.

## Major capabilities

1. Project management and floor-plan import
2. Calibrated, zoomable survey canvas
3. Survey-point capture and heatmap visualization
4. Connectivity diagnostics: latency, DNS, route diagnostics, loss, throughput
5. Mist organization/site/AP/client integration
6. AP and client inventory with caching and paging
7. Roaming and client journey analysis
8. macOS RF inspection and nearby-network scan
9. CSV/PDF report generation
10. Secure configuration import by file or QR code

## Out of scope for initial production release

- Private iOS Wi-Fi APIs
- Fabricated RSSI/channel values on iOS
- Raw packet capture on standard iOS devices
- Spectrum analysis without supported external hardware
