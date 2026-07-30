import SwiftUI

struct MacWiFiScanView: View {
    var body: some View {
        ContentUnavailableView("Native RF workspace", systemImage: "wifi.router", description: Text("CoreWLAN scan, noise, PHY and channel analytics will be implemented in the macOS RF module."))
    }
}
