import XCTest
@testable import RFVisionEnterprise

final class FoundationSmokeTests: XCTestCase {
    func testFoundationSmoke() {
        XCTAssertEqual("RFVisionEnterprise".lowercased(), "rfvisionenterprise")
    }

    func testAllSurveyModesSelectExpectedProviders() {
        let local = LocalDeviceMockProvider()
        let vendor = MockMistMeasurementProvider()

        XCTAssertEqual(
            SurveyProviderSelection.providers(for: .general, local: local, vendor: vendor)
                .map { $0.capability.id },
            [LocalDeviceMockProvider.id]
        )
        XCTAssertEqual(
            SurveyProviderSelection.providers(for: .vendorAssisted, local: local, vendor: vendor)
                .map { $0.capability.id },
            [MockMistMeasurementProvider.id]
        )
        XCTAssertEqual(
            SurveyProviderSelection.providers(for: .hybrid, local: local, vendor: vendor)
                .map { $0.capability.id },
            [LocalDeviceMockProvider.id, MockMistMeasurementProvider.id]
        )
    }

    func testDomainModelsCodableRoundTrip() throws {
        let project = RFProject(
            name: "General Survey",
            surveyMode: .general,
            floorPlans: [
                FloorPlan(name: "First Floor", assetName: "first-floor.png", pixelWidth: 1200, pixelHeight: 800)
            ]
        )
        let data = try JSONEncoder().encode(project)
        XCTAssertEqual(try JSONDecoder().decode(RFProject.self, from: data), project)
    }

    func testCapabilityAggregationExcludesUnavailableProviders() {
        let available = ProviderCapability(
            id: "available",
            displayName: "Available",
            supportedMeasurements: [.latency, .jitter],
            availability: .available
        )
        let unavailable = ProviderCapability(
            id: "unavailable",
            displayName: "Unavailable",
            supportedMeasurements: [.rssi],
            availability: .unavailable(reason: "Not supported on this platform")
        )
        let summary = ProviderCapabilitySummary(providers: [unavailable, available])

        XCTAssertEqual(summary.availableMeasurements, [.latency, .jitter])
        XCTAssertEqual(summary.providers.map(\.id), ["available", "unavailable"])
    }

    func testHybridPointContainsLocalAndMockVendorMeasurements() async throws {
        let project = RFProject(name: "Hybrid", surveyMode: .hybrid)
        let session = SurveySession(
            projectID: project.id,
            mode: .hybrid,
            enabledProviderIDs: [LocalDeviceMockProvider.id, MockMistMeasurementProvider.id]
        )
        let context = SurveyCaptureContext(
            projectID: project.id,
            sessionID: session.id,
            position: NormalizedPoint(x: 0.25, y: 0.75)
        )
        let localBatch = try await LocalDeviceMockProvider().capture(context: context)
        let vendorBatch = try await MockMistMeasurementProvider().capture(context: context)
        let point = SurveyPoint(
            position: context.position,
            measurementBatches: [localBatch, vendorBatch]
        )

        XCTAssertEqual(point.measurementBatches.count, 2)
        XCTAssertTrue(point.measurementBatches.flatMap(\.measurements).contains {
            $0.source.category == .localDevice
        })
        XCTAssertTrue(point.measurementBatches.flatMap(\.measurements).contains {
            $0.source.category == .vendorCloud
        })
    }

    func testGeneralProjectCapturesWithoutVendorConfiguration() async throws {
        let project = RFProject(name: "General", surveyMode: .general)
        let session = SurveySession(
            projectID: project.id,
            mode: .general,
            enabledProviderIDs: [LocalDeviceMockProvider.id]
        )
        let context = SurveyCaptureContext(
            projectID: project.id,
            sessionID: session.id,
            position: NormalizedPoint(x: 0.5, y: 0.5)
        )
        let point = SurveyPoint(
            position: context.position,
            measurementBatches: [try await LocalDeviceMockProvider().capture(context: context)]
        )

        XCTAssertEqual(point.measurementBatches.map(\.providerID), [LocalDeviceMockProvider.id])
        XCTAssertFalse(point.measurementBatches.flatMap(\.measurements).isEmpty)
    }

    func testProjectAndSessionPersistenceReloadWithoutSecrets() async throws {
        let directory = temporaryDirectory()
        let projects = LocalJSONProjectRepository(directory: directory)
        let sessions = LocalJSONSurveySessionRepository(directory: directory)
        let capturedAt = Date(timeIntervalSince1970: 1_700_000_000)
        let project = RFProject(
            name: "Persisted General",
            surveyMode: .general,
            createdAt: capturedAt,
            modifiedAt: capturedAt
        )
        let session = SurveySession(
            projectID: project.id,
            mode: .general,
            enabledProviderIDs: [LocalDeviceMockProvider.id],
            startedAt: capturedAt
        )

        try await projects.save(project)
        try await sessions.save(session)

        let reloadedProject = try await projects.project(id: project.id)
        let reloadedSession = try await sessions.session(id: session.id)
        XCTAssertEqual(reloadedProject, project)
        XCTAssertEqual(reloadedSession, session)

        let persistedText = try String(
            contentsOf: directory.appendingPathComponent("projects.json"),
            encoding: .utf8
        ) + String(
            contentsOf: directory.appendingPathComponent("sessions.json"),
            encoding: .utf8
        )
        XCTAssertFalse(persistedText.lowercased().contains("token"))
        XCTAssertFalse(persistedText.lowercased().contains("secret"))
        XCTAssertFalse(persistedText.lowercased().contains("organizationid"))
    }

    func testUnsupportedSchemaVersionIsRejected() async throws {
        let directory = temporaryDirectory()
        let repository = LocalJSONProjectRepository(directory: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data(#"{"schemaVersion":999,"values":[]}"#.utf8)
            .write(to: directory.appendingPathComponent("projects.json"), options: .atomic)

        do {
            _ = try await repository.allProjects()
            XCTFail("Expected unsupported schema version error")
        } catch let error as RepositoryError {
            XCTAssertEqual(
                error,
                .unsupportedSchemaVersion(found: 999, supported: RFProject.currentSchemaVersion)
            )
        }
    }

    func testCoreDomainEncodingHasNoVendorSpecificKeys() throws {
        let project = RFProject(name: "Neutral", surveyMode: .vendorAssisted)
        let session = SurveySession(
            projectID: project.id,
            mode: .vendorAssisted,
            enabledProviderIDs: ["provider"]
        )
        let point = SurveyPoint(
            position: NormalizedPoint(x: 0, y: 1),
            measurementBatches: [
                MeasurementBatch(
                    providerID: "provider",
                    measurements: [
                        MeasurementValue(
                            kind: .rssi,
                            value: .integer(-60),
                            unit: "dBm",
                            source: MeasurementSource(category: .vendorCloud, providerID: "provider")
                        )
                    ]
                )
            ]
        )
        let encoder = JSONEncoder()
        let encoded = [
            try String(decoding: encoder.encode(project), as: UTF8.self),
            try String(decoding: encoder.encode(session), as: UTF8.self),
            try String(decoding: encoder.encode(point), as: UTF8.self),
        ].joined().lowercased()

        XCTAssertFalse(encoded.contains("mist"))
        XCTAssertFalse(encoded.contains("organization"))
        XCTAssertFalse(encoded.contains("siteid"))
        XCTAssertFalse(encoded.contains("clientmac"))
        XCTAssertFalse(encoded.contains("token"))
    }

    private func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("RFVisionEnterpriseTests-\(UUID().uuidString)", isDirectory: true)
    }
}
