# Test Strategy

## Build gates

Every feature branch must build for:

- An available iOS Simulator destination
- macOS

## Test layers

- Unit tests for parsers, coordinate transforms, scoring, pagination, and API mapping
- Repository tests with fixture JSON
- UI smoke tests for project creation, floor-plan import, and survey-point capture
- Manual device tests for SSID/BSSID permissions and QR scanning
- Manual macOS tests for CoreWLAN permissions and scan behavior

## No-fabrication rule

Tests must explicitly verify that unavailable metrics render as unavailable and are never silently replaced with zero.
