# Release Strategy

## Channels

1. Local developer builds
2. Internal TestFlight group
3. External TestFlight group if needed
4. Managed production distribution or App Store release after review

## Versioning

Use semantic marketing versions and monotonically increasing build numbers.

## TestFlight gate

A build may be uploaded only when:

- iOS archive succeeds
- Privacy usage descriptions are accurate
- No production secrets are embedded
- Core workflows pass manual smoke tests
- Known limitations are listed in Test Information
