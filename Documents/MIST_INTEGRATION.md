# Mist Integration

## Configuration

Required fields:

- API base URL / region
- API token
- Organization ID
- Optional default site ID

Never commit real values. Use `Config/MistConfig.sample.json` only as a template.

## Planned repositories

- OrganizationRepository
- SiteRepository
- DeviceRepository
- WirelessClientRepository
- ClientEventRepository

## Requirements

- Cache sites and AP inventory locally.
- Resolve AP UUID/MAC/BSSID to AP name through a normalized lookup index.
- Paginate large device lists in the UI.
- Apply request timeout, cancellation, retry policy, and meaningful error mapping.
- Avoid rapid duplicate polling that only returns cached telemetry.
- Record whether RSSI is AP-side or client-side.
