import SwiftUI

struct TestView: View {
    @EnvironmentObject private var monitor: WirelessMonitor
    @State private var host = "www.apple.com"
    @State private var results: [DiagnosticResult] = []
    @State private var running = false

    var body: some View {
        NavigationStack {
            List {
                Section("Target") { TextField("Hostname or URL", text: $host) }
                Section("Diagnostics") {
                    Button("Run HTTPS Ping") { run { await NetworkProbe.httpsPing(host: host) } }
                    Button("Resolve DNS") { run { await NetworkProbe.dns(host: normalizedHost) } }
                    Button("Traceroute") { run { await NetworkProbe.traceroute(host: normalizedHost) } }
                    Button("Refresh network snapshot") { Task { await monitor.runBasicTest() } }
                }
                if running { Section { ProgressView("Running diagnostic…") } }
                Section("Results") {
                    if results.isEmpty { Text("No results yet").foregroundStyle(.secondary) }
                    ForEach(results) { result in
                        VStack(alignment: .leading, spacing: 6) {
                            Label(result.title, systemImage: result.success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill").foregroundStyle(result.success ? .green : .orange)
                            Text(result.detail).font(.system(.caption, design: .monospaced)).textSelection(.enabled)
                        }.padding(.vertical, 4)
                    }
                }
            }.navigationTitle("Diagnostics")
        }
    }

    private var normalizedHost: String {
        host.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "").split(separator: "/").first.map(String.init) ?? host
    }

    private func run(_ operation: @escaping () async -> DiagnosticResult) {
        running = true
        Task { let value = await operation(); await MainActor.run { results.insert(value, at: 0); running = false } }
    }
}
