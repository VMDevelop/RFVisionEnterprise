import Foundation
import Network
#if canImport(NetworkExtension)
import NetworkExtension
#endif

@MainActor
final class WirelessMonitor: ObservableObject {
    @Published var snapshot = NetworkSnapshot()
    @Published var isTesting = false
    private let pathMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "RFVisionEnterprise.NetworkPath")

    init() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            let kind: ConnectionKind = path.status != .satisfied ? .offline : path.usesInterfaceType(.wifi) ? .wifi : path.usesInterfaceType(.cellular) ? .cellular : path.usesInterfaceType(.wiredEthernet) ? .ethernet : .other
            Task { @MainActor in self?.snapshot.kind = kind; self?.snapshot.status = path.status == .satisfied ? "Connected" : "Offline"; self?.snapshot.updatedAt = Date(); self?.refreshWiFi() }
        }
        pathMonitor.start(queue: queue)
    }

    func refreshWiFi() {
        snapshot.ipv4 = IPAddressReader.ipv4Address()
        #if os(iOS)
        if #available(iOS 14.0, *) {
            NEHotspotNetwork.fetchCurrent { [weak self] network in
                Task { @MainActor in self?.snapshot.ssid = network?.ssid; self?.snapshot.bssid = network?.bssid; self?.snapshot.updatedAt = Date() }
            }
        }
        #endif
    }

    func runBasicTest() async {
        isTesting = true; defer { isTesting = false }
        var values: [Double] = []; var failures = 0
        for _ in 0..<3 {
            let start = Date()
            do { _ = try await URLSession.shared.data(from: URL(string: "https://www.apple.com/library/test/success.html")!); values.append(Date().timeIntervalSince(start) * 1000) } catch { failures += 1 }
        }
        snapshot.latencyMs = values.isEmpty ? nil : values.reduce(0,+) / Double(values.count)
        snapshot.lossPercent = Double(failures) / 3.0 * 100
        snapshot.updatedAt = Date()
    }
}
