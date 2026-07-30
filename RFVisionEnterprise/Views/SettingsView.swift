import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: MeasurementStore
    @EnvironmentObject private var location: LocationPermission
    @State private var importingConfig = false
    @State private var showToken = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Mist Cloud") {
                    TextField("API base URL", text: $store.mistConfiguration.baseURL)
                    TextField("Organization ID", text: $store.mistConfiguration.organizationID)
                    if showToken { TextField("API token", text: $store.mistConfiguration.token) } else { SecureField("API token", text: $store.mistConfiguration.token) }
                    Toggle("Show token", isOn: $showToken)
                    TextField("Default site ID", text: $store.mistConfiguration.defaultSiteID)
                    Button("Import Mist Configuration") { importingConfig = true }
                    Text(store.mistConfiguration.isConfigured ? "Configuration ready" : "Organization ID and token are required").font(.caption).foregroundStyle(store.mistConfiguration.isConfigured ? .green : .secondary)
                }
                Section("Wi‑Fi permission") {
                    LabeledContent("Location", value: permissionText)
                    Button("Request Location Permission") { location.request() }
                    Text("Precise location may be required before iOS returns the current SSID and BSSID.").font(.caption).foregroundStyle(.secondary)
                }
                Section("Data architecture") {
                    Label("Projects are cached locally for offline use", systemImage: "internaldrive")
                    Label("Mist credentials remain on this device", systemImage: "lock.shield")
                    Label("Survey points use normalized floor-plan coordinates", systemImage: "map")
                }
                Section("About") {
                    LabeledContent("App", value: "RF Vision Enterprise")
                    LabeledContent("Foundation", value: "0.1.0")
                    Text("Production-oriented foundation for wireless projects, floor surveys, diagnostics and cloud-assisted RF workflows.")
                }
            }
            .navigationTitle("Settings")
            .fileImporter(isPresented: $importingConfig, allowedContentTypes: [.json, .plainText]) { result in
                guard case .success(let url) = result, url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }
                guard let data = try? Data(contentsOf: url) else { return }
                if let config = try? JSONDecoder().decode(MistConfiguration.self, from: data) { store.mistConfiguration = config }
            }
        }
    }

    private var permissionText: String {
        switch location.status {
        case .authorizedAlways, .authorizedWhenInUse: return "Authorized"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not requested"
        @unknown default: return "Unknown"
        }
    }
}
