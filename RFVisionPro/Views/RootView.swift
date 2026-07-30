import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            DashboardView().tabItem { Label("Home", systemImage: "wave.3.right.circle") }
            HistoryView().tabItem { Label("Projects", systemImage: "folder") }
            HybridSurveyView().tabItem { Label("Survey", systemImage: "map") }
            TestView().tabItem { Label("Diagnostics", systemImage: "stethoscope") }
            SettingsView().tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
