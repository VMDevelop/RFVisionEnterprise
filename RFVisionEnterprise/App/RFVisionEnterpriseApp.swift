import SwiftUI

@main
struct RFVisionEnterpriseApp: App {
    @StateObject private var monitor = WirelessMonitor()
    @StateObject private var store = MeasurementStore()
    @StateObject private var location = LocationPermission()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(monitor)
                .environmentObject(store)
                .environmentObject(location)
        }
    }
}
