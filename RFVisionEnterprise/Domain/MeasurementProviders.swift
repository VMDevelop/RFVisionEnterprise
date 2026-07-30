import Foundation

enum ProviderAvailability: Codable, Sendable, Equatable {
    case available
    case unavailable(reason: String)
}

struct ProviderCapability: Codable, Sendable, Identifiable, Equatable {
    let id: String
    let displayName: String
    let supportedMeasurements: Set<MeasurementKind>
    let availability: ProviderAvailability
}

struct SurveyCaptureContext: Sendable, Equatable {
    let projectID: UUID
    let sessionID: UUID
    let position: NormalizedPoint
}

protocol SurveyMeasurementProvider: Sendable {
    var capability: ProviderCapability { get }
    func capture(context: SurveyCaptureContext) async throws -> MeasurementBatch
}

protocol NetworkIdentityProvider: SurveyMeasurementProvider {
    func currentNetworkIdentity() async throws -> NetworkIdentity
}

protocol ActiveDiagnosticsProvider: SurveyMeasurementProvider {}
protocol NativeRFProvider: SurveyMeasurementProvider {}
protocol VendorWirelessProvider: SurveyMeasurementProvider {}

struct ProviderCapabilitySummary: Sendable, Equatable {
    let providers: [ProviderCapability]
    let availableMeasurements: Set<MeasurementKind>

    init(providers: [ProviderCapability]) {
        self.providers = providers.sorted { $0.id < $1.id }
        self.availableMeasurements = providers.reduce(into: []) { result, capability in
            if case .available = capability.availability {
                result.formUnion(capability.supportedMeasurements)
            }
        }
    }
}

struct LocalDeviceMockProvider: NetworkIdentityProvider {
    static let id = "localDevice"

    let capability = ProviderCapability(
        id: id,
        displayName: "Local Device",
        supportedMeasurements: [.localIPv4, .localIPv6],
        availability: .available
    )

    func currentNetworkIdentity() async throws -> NetworkIdentity {
        NetworkIdentity(localIPv4: "192.0.2.10", localIPv6: "2001:db8::10")
    }

    func capture(context: SurveyCaptureContext) async throws -> MeasurementBatch {
        let identity = try await currentNetworkIdentity()
        let values = [
            MeasurementValue(
                kind: .localIPv4,
                value: .text(identity.localIPv4 ?? ""),
                source: .localDevice
            ),
            MeasurementValue(
                kind: .localIPv6,
                value: .text(identity.localIPv6 ?? ""),
                source: .localDevice
            ),
        ]
        return MeasurementBatch(providerID: capability.id, measurements: values)
    }
}

struct MockMistMeasurementProvider: VendorWirelessProvider {
    static let id = "mistCloud"
    static let source = MeasurementSource(category: .vendorCloud, providerID: id)

    let capability = ProviderCapability(
        id: id,
        displayName: "Mock Mist Cloud",
        supportedMeasurements: [.rssi, .snr, .vendorClientHealth],
        availability: .available
    )

    func capture(context: SurveyCaptureContext) async throws -> MeasurementBatch {
        MeasurementBatch(
            providerID: capability.id,
            measurements: [
                MeasurementValue(kind: .rssi, value: .integer(-58), unit: "dBm", source: Self.source),
                MeasurementValue(kind: .snr, value: .integer(31), unit: "dB", source: Self.source),
                MeasurementValue(kind: .vendorClientHealth, value: .integer(92), unit: "percent", source: Self.source),
            ]
        )
    }
}

enum SurveyProviderSelection {
    static func providers(
        for mode: SurveyMode,
        local: any SurveyMeasurementProvider,
        vendor: any SurveyMeasurementProvider
    ) -> [any SurveyMeasurementProvider] {
        switch mode {
        case .general:
            return [local]
        case .vendorAssisted:
            return [vendor]
        case .hybrid:
            return [local, vendor]
        }
    }

    static func capabilities(
        for mode: SurveyMode,
        local: any SurveyMeasurementProvider,
        vendor: any SurveyMeasurementProvider
    ) -> ProviderCapabilitySummary {
        ProviderCapabilitySummary(
            providers: providers(for: mode, local: local, vendor: vendor).map(\.capability)
        )
    }
}
