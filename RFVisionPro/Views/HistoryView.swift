import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: MeasurementStore
    @State private var newName = ""

    var body: some View {
        NavigationStack {
            List {
                Section("New project") {
                    TextField("Project name", text: $newName)
                    Button("Create Survey Project") { store.createProject(name: newName); newName = "" }
                }
                Section("Projects") {
                    if store.projects.isEmpty { ContentUnavailableView("No projects", systemImage: "folder.badge.plus", description: Text("Create a project before starting a floor survey.")) }
                    ForEach(store.projects) { project in
                        Button {
                            store.selectedProjectID = project.id
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) { Text(project.name).font(.headline); Text("\(project.points.count) points • \(project.modifiedAt.formatted(date: .abbreviated, time: .shortened))").foregroundStyle(.secondary).font(.caption) }
                                Spacer()
                                if store.selectedProjectID == project.id { Image(systemName: "checkmark.circle.fill").foregroundStyle(.blue) }
                            }
                        }.buttonStyle(.plain)
                    }.onDelete { offsets in for offset in offsets { store.deleteProject(id: store.projects[offset].id) } }
                }
            }.navigationTitle("Projects")
        }
    }
}
