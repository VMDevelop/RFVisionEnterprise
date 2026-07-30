import Foundation

enum ConnectionKind: String, Codable, CaseIterable { case wifi = "Wi‑Fi", cellular = "Cellular", ethernet = "Ethernet", other = "Other", offline = "Offline" }

struct NetworkSnapshot: Codable, Equatable {
    var kind: ConnectionKind = .offline
    var status = "Offline"
    var ssid: String?
    var bssid: String?
    var ipv4: String?
    var latencyMs: Double?
    var lossPercent: Double?
    var downloadMbps: Double?
    var updatedAt = Date()
}

struct MistConfiguration: Codable, Equatable {
    var baseURL = "https://api.mist.com"
    var organizationID = ""
    var token = ""
    var defaultSiteID = ""
    var isConfigured: Bool { !organizationID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}

struct MistSite: Codable, Identifiable, Hashable { let id: String; let name: String }
struct MistDevice: Codable, Identifiable, Hashable { let id: String; let name: String; let model: String?; let mac: String?; let status: String? }
