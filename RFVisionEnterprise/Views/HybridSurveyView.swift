import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct HybridSurveyView: View {
    @EnvironmentObject private var store: MeasurementStore
    @State private var pointName = ""
    @State private var note = ""
    @State private var marker = CGPoint(x: 0.5, y: 0.5)
    @State private var zoom: CGFloat = 1
    @State private var baseZoom: CGFloat = 1
    @State private var pan = CGSize.zero
    @State private var basePan = CGSize.zero
    @State private var importingPlan = false

    var body: some View {
        NavigationStack {
            Group {
                if let project = store.selectedProject {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            projectHeader(project)
                            floorPlan(project)
                            pointEditor(project)
                            capturedPoints(project)
                        }.padding()
                    }
                    .navigationTitle("Survey")
                    .fileImporter(isPresented: $importingPlan, allowedContentTypes: [.image]) { result in
                        guard case .success(let url) = result, url.startAccessingSecurityScopedResource() else { return }
                        defer { url.stopAccessingSecurityScopedResource() }
                        if let data = try? Data(contentsOf: url) { var updated = project; updated.floorPlanData = data; store.updateProject(updated) }
                    }
                } else {
                    ContentUnavailableView("Select a project", systemImage: "map", description: Text("Create or select a project in the Projects tab."))
                }
            }
        }
    }

    @ViewBuilder private func projectHeader(_ project: SurveyProject) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(project.name).font(.title2.bold())
            Text("Site: \(project.siteID.isEmpty ? "Not selected" : project.siteID) • Client: \(project.clientMAC.isEmpty ? "Not configured" : project.clientMAC)").font(.caption).foregroundStyle(.secondary)
            HStack { Button("Import Floor Plan") { importingPlan = true }; Spacer(); Button("Reset View") { zoom = 1; baseZoom = 1; pan = .zero; basePan = .zero } }
        }.padding().background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder private func floorPlan(_ project: SurveyProject) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack { Text("Floor plan").font(.headline); Spacer(); Text(String(format: "%.1fx", zoom)).foregroundStyle(.secondary) }
            GeometryReader { geo in
                ZStack {
                    RoundedRectangle(cornerRadius: 18).fill(Color.secondary.opacity(0.12))
                    if let data = project.floorPlanData, let image = platformImage(data: data) {
                        image.resizable().scaledToFit().scaleEffect(zoom).offset(pan)
                    } else {
                        VStack { Image(systemName: "photo.badge.plus").font(.largeTitle); Text("Import PNG or JPEG floor plan") }.foregroundStyle(.secondary)
                    }
                    ForEach(project.points) { point in
                        Circle().fill(color(for: point.reading.rssi)).frame(width: 18, height: 18).overlay(Circle().stroke(.white, lineWidth: 2)).position(x: geo.size.width * point.x, y: geo.size.height * point.y)
                    }
                    Circle().fill(.blue).frame(width: 26, height: 26).overlay(Circle().stroke(.white, lineWidth: 3)).position(x: geo.size.width * marker.x, y: geo.size.height * marker.y)
                }
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0).onEnded { value in
                    marker = CGPoint(x: min(max(value.location.x / geo.size.width, 0), 1), y: min(max(value.location.y / geo.size.height, 0), 1))
                })
                .simultaneousGesture(MagnificationGesture().onChanged { value in zoom = min(max(baseZoom * value, 1), 8) }.onEnded { _ in baseZoom = zoom })
            }.frame(minHeight: 420)
            HStack { Button { zoom = max(1, zoom - 0.5); baseZoom = zoom } label: { Image(systemName: "minus.magnifyingglass") }; Slider(value: $zoom, in: 1...8, step: 0.25).onChange(of: zoom) { _, value in baseZoom = value }; Button { zoom = min(8, zoom + 0.5); baseZoom = zoom } label: { Image(systemName: "plus.magnifyingglass") } }
            Text("Tap the exact location to place the blue capture marker. Pinch or use the slider to zoom.").font(.caption).foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private func pointEditor(_ project: SurveyProject) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Capture point").font(.headline)
            TextField("Point name", text: $pointName)
            TextField("Notes", text: $note, axis: .vertical)
            if let rf = store.liveRF { Text("Live: \(rf.rssi.map { "\($0) dBm" } ?? "No RSSI") • \(rf.apName ?? rf.apID ?? "Unknown AP")").foregroundStyle(.secondary) }
            Button { capture(project) } label: { Label("Capture Survey Point", systemImage: "scope").frame(maxWidth: .infinity) }.buttonStyle(.borderedProminent)
        }.padding().background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder private func capturedPoints(_ project: SurveyProject) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Captured points (\(project.points.count))").font(.headline)
            ForEach(project.points.reversed()) { point in
                HStack { Circle().fill(color(for: point.reading.rssi)).frame(width: 12, height: 12); VStack(alignment: .leading) { Text(point.name).font(.headline); Text("\(point.reading.rssi.map { "\($0) dBm" } ?? "No RF") • \(point.reading.apName ?? "Unknown AP")").font(.caption).foregroundStyle(.secondary) }; Spacer(); Text(point.createdAt.formatted(date: .omitted, time: .shortened)).font(.caption) }
                Divider()
            }
        }
    }

    private func capture(_ project: SurveyProject) {
        let reading = store.liveRF ?? RFReading(ssid: nil, updatedAt: Date())
        let point = SurveyPoint(name: pointName.isEmpty ? "Point \(project.points.count + 1)" : pointName, note: note, x: marker.x, y: marker.y, reading: reading)
        store.addPoint(point, to: project.id); pointName = ""; note = ""
    }

    private func color(for rssi: Int?) -> Color { guard let rssi else { return .gray }; if rssi >= -55 { return .green }; if rssi >= -67 { return .mint }; if rssi >= -75 { return .orange }; return .red }

    private func platformImage(data: Data) -> Image? {
        #if os(iOS)
        guard let value = UIImage(data: data) else { return nil }; return Image(uiImage: value)
        #elseif os(macOS)
        guard let value = NSImage(data: data) else { return nil }; return Image(nsImage: value)
        #endif
    }
}
