import Foundation

struct NormalizedPoint: Codable, Sendable, Equatable {
    let x: Double
    let y: Double

    init(x: Double, y: Double) {
        self.x = min(max(x, 0), 1)
        self.y = min(max(y, 0), 1)
    }
}

enum SurveyMode: String, Codable, Sendable, CaseIterable {
    case general
    case vendorAssisted
    case hybrid
}

struct FloorPlan: Codable, Sendable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var assetName: String
    var pixelWidth: Int
    var pixelHeight: Int

    init(
        id: UUID = UUID(),
        name: String,
        assetName: String,
        pixelWidth: Int,
        pixelHeight: Int
    ) {
        self.id = id
        self.name = name
        self.assetName = assetName
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
    }
}

struct RFProject: Codable, Sendable, Identifiable, Equatable {
    static let currentSchemaVersion = 1

    let id: UUID
    var schemaVersion: Int
    var name: String
    var surveyMode: SurveyMode
    var floorPlans: [FloorPlan]
    var sessionIDs: [UUID]
    var createdAt: Date
    var modifiedAt: Date

    init(
        id: UUID = UUID(),
        schemaVersion: Int = currentSchemaVersion,
        name: String,
        surveyMode: SurveyMode,
        floorPlans: [FloorPlan] = [],
        sessionIDs: [UUID] = [],
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.name = name
        self.surveyMode = surveyMode
        self.floorPlans = floorPlans
        self.sessionIDs = sessionIDs
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

enum MeasurementSourceCategory: String, Codable, Sendable, CaseIterable {
    case localDevice
    case nativeWiFi
    case activeTest
    case vendorCloud
    case imported
    case externalSensor
}

struct MeasurementSource: Codable, Sendable, Hashable, Equatable {
    let category: MeasurementSourceCategory
    let providerID: String

    static let localDevice = MeasurementSource(category: .localDevice, providerID: "localDevice")
    static let nativeWiFi = MeasurementSource(category: .nativeWiFi, providerID: "nativeWiFi")
    static let activeTest = MeasurementSource(category: .activeTest, providerID: "activeTest")
    static let imported = MeasurementSource(category: .imported, providerID: "imported")
    static let externalSensor = MeasurementSource(category: .externalSensor, providerID: "externalSensor")
}

enum MeasurementKind: String, Codable, Sendable, CaseIterable {
    case rssi
    case noise
    case snr
    case channel
    case band
    case phyMode
    case transmitRate
    case receiveRate
    case latency
    case jitter
    case packetLoss
    case dnsResolutionTime
    case downloadThroughput
    case uploadThroughput
    case ssid
    case bssid
    case localIPv4
    case localIPv6
    case connectedAP
    case roamInterruption
    case vendorClientHealth
}

enum MeasurementScalar: Codable, Sendable, Equatable {
    case decimal(Double)
    case integer(Int)
    case text(String)
    case unavailable(reason: String)
}

struct MeasurementValue: Codable, Sendable, Identifiable, Equatable {
    let id: UUID
    let kind: MeasurementKind
    let value: MeasurementScalar
    let unit: String?
    let source: MeasurementSource
    let capturedAt: Date

    init(
        id: UUID = UUID(),
        kind: MeasurementKind,
        value: MeasurementScalar,
        unit: String? = nil,
        source: MeasurementSource,
        capturedAt: Date = Date()
    ) {
        self.id = id
        self.kind = kind
        self.value = value
        self.unit = unit
        self.source = source
        self.capturedAt = capturedAt
    }
}

struct NetworkIdentity: Codable, Sendable, Equatable {
    var ssid: String?
    var bssid: String?
    var localIPv4: String?
    var localIPv6: String?
}

struct AccessPointIdentity: Codable, Sendable, Identifiable, Equatable {
    let id: String
    var displayName: String?
    var bssid: String?
}

struct SurveyNote: Codable, Sendable, Identifiable, Equatable {
    let id: UUID
    var text: String
    let createdAt: Date

    init(id: UUID = UUID(), text: String, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}

struct MeasurementBatch: Codable, Sendable, Identifiable, Equatable {
    let id: UUID
    let providerID: String
    let capturedAt: Date
    var measurements: [MeasurementValue]

    init(
        id: UUID = UUID(),
        providerID: String,
        capturedAt: Date = Date(),
        measurements: [MeasurementValue]
    ) {
        self.id = id
        self.providerID = providerID
        self.capturedAt = capturedAt
        self.measurements = measurements
    }
}

struct SurveyPoint: Codable, Sendable, Identifiable, Equatable {
    let id: UUID
    var position: NormalizedPoint
    var notes: [SurveyNote]
    var networkIdentity: NetworkIdentity?
    var accessPoint: AccessPointIdentity?
    var measurementBatches: [MeasurementBatch]
    let capturedAt: Date

    init(
        id: UUID = UUID(),
        position: NormalizedPoint,
        notes: [SurveyNote] = [],
        networkIdentity: NetworkIdentity? = nil,
        accessPoint: AccessPointIdentity? = nil,
        measurementBatches: [MeasurementBatch] = [],
        capturedAt: Date = Date()
    ) {
        self.id = id
        self.position = position
        self.notes = notes
        self.networkIdentity = networkIdentity
        self.accessPoint = accessPoint
        self.measurementBatches = measurementBatches
        self.capturedAt = capturedAt
    }
}

struct SurveySession: Codable, Sendable, Identifiable, Equatable {
    let id: UUID
    let projectID: UUID
    var mode: SurveyMode
    var enabledProviderIDs: [String]
    var points: [SurveyPoint]
    let startedAt: Date
    var endedAt: Date?

    init(
        id: UUID = UUID(),
        projectID: UUID,
        mode: SurveyMode,
        enabledProviderIDs: [String],
        points: [SurveyPoint] = [],
        startedAt: Date = Date(),
        endedAt: Date? = nil
    ) {
        self.id = id
        self.projectID = projectID
        self.mode = mode
        self.enabledProviderIDs = enabledProviderIDs
        self.points = points
        self.startedAt = startedAt
        self.endedAt = endedAt
    }
}
