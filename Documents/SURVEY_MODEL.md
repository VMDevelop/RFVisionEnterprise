# Survey Model

## Project entities

- SurveyProject
- FloorPlan
- ScaleCalibration
- SurveySession
- SurveyPoint
- RFMeasurement
- DiagnosticMeasurement
- AccessPointReference

## Coordinates

Store points using normalized image coordinates plus the original image dimensions. Rendering must account for aspect-fit bounds, zoom, and pan transforms.

## Measurement fields

- Timestamp
- SSID/BSSID
- AP identifier and resolved AP name
- Band/channel
- RSSI/SNR and provenance
- Latency/loss/throughput
- Position and notes
- Sample count and aggregation method

## Sampling

Support quick, standard, and validation profiles. Use median for noisy telemetry while retaining min/max and raw sample timestamps.
