import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var monitor: WirelessMonitor
    @EnvironmentObject private var store: MeasurementStore

    private let columns = [GridItem(.adaptive(minimum: 155), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("RF Vision Enterprise").font(.largeTitle.bold())
                        Text("Wireless operations, survey projects and client experience in one workspace.").foregroundStyle(.secondary)
                    }
                    statusCard
                    LazyVGrid(columns: columns, spacing: 14) {
                        MetricCard(title: "Connection", value: monitor.snapshot.kind.rawValue, subtitle: monitor.snapshot.status, icon: "network")
                        MetricCard(title: "Wi‑Fi", value: monitor.snapshot.ssid ?? "Unavailable", subtitle: monitor.snapshot.bssid ?? "Current BSSID unavailable", icon: "wifi")
                        MetricCard(title: "Live RSSI", value: store.liveRF?.rssi.map { "\($0) dBm" } ?? "Waiting", subtitle: store.liveRF?.apName ?? "Connect Mist in Settings", icon: "antenna.radiowaves.left.and.right")
                        MetricCard(title: "Band / Channel", value: bandChannel, subtitle: store.liveRF?.ssid ?? "No Mist sample", icon: "square.stack.3d.up")
                        MetricCard(title: "Latency", value: monitor.snapshot.latencyMs.map { String(format: "%.1f ms", $0) } ?? "Not tested", subtitle: "HTTPS application round trip", icon: "timer")
                        MetricCard(title: "Local IPv4", value: monitor.snapshot.ipv4 ?? "Unavailable", subtitle: "Active Wi‑Fi interface", icon: "number")
                    }
                    if let project = store.selectedProject {
                        NavigationLink { HybridSurveyView() } label: {
                            HStack { VStack(alignment: .leading) { Text("Continue \(project.name)").font(.headline); Text("\(project.points.count) captured points").foregroundStyle(.secondary) }; Spacer(); Image(systemName: "arrow.right.circle.fill").font(.title2) }
                                .padding().background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                        }.buttonStyle(.plain)
                    }
                }.padding()
            }
            .toolbar { Button { monitor.refreshWiFi(); Task { await monitor.runBasicTest() } } label: { if monitor.isTesting { ProgressView() } else { Image(systemName: "arrow.clockwise") } } }
        }
    }

    private var statusCard: some View {
        HStack(spacing: 16) {
            Image(systemName: monitor.snapshot.status == "Connected" ? "checkmark.circle.fill" : "xmark.circle.fill").font(.system(size: 44)).foregroundStyle(monitor.snapshot.status == "Connected" ? .green : .red)
            VStack(alignment: .leading) { Text(monitor.snapshot.status).font(.title2.bold()); Text("Updated \(monitor.snapshot.updatedAt.formatted(date: .omitted, time: .standard))").foregroundStyle(.secondary) }
            Spacer()
        }.padding().background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22))
    }

    private var bandChannel: String {
        guard let rf = store.liveRF else { return "Waiting" }
        let band = rf.band ?? "—"; let channel = rf.channel.map(String.init) ?? "—"
        return "\(band) / Ch \(channel)"
    }
}
