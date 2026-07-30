import SwiftUI

@MainActor
final class DomainProviderDevelopmentModel: ObservableObject {
    @Published private(set) var mode: SurveyMode = .general
    @Published private(set) var project: RFProject?
    @Published private(set) var session: SurveySession?
    @Published private(set) var capabilities = ProviderCapabilitySummary(providers: [])
    @Published private(set) var status = "Choose a survey mode."

    private let localProvider = LocalDeviceMockProvider()
    private let vendorProvider = MockMistMeasurementProvider()
    private let projectRepository: any ProjectRepository
    private let sessionRepository: any SurveySessionRepository

    init() {
        let directory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("RFVisionEnterprise/DomainProviderDevelopment", isDirectory: true)
        projectRepository = LocalJSONProjectRepository(directory: directory)
        sessionRepository = LocalJSONSurveySessionRepository(directory: directory)
        select(.general)
    }

    func select(_ newMode: SurveyMode) {
        mode = newMode
        capabilities = SurveyProviderSelection.capabilities(
            for: newMode,
            local: localProvider,
            vendor: vendorProvider
        )
    }

    func createProject() {
        let selectedMode = mode
        let providers = SurveyProviderSelection.providers(
            for: selectedMode,
            local: localProvider,
            vendor: vendorProvider
        )
        var newProject = RFProject(
            name: "\(selectedMode.title) Development Project",
            surveyMode: selectedMode
        )
        let newSession = SurveySession(
            projectID: newProject.id,
            mode: selectedMode,
            enabledProviderIDs: providers.map { $0.capability.id }
        )
        newProject.sessionIDs = [newSession.id]
        project = newProject
        session = newSession
        status = "Created a provider-neutral \(selectedMode.title) project."

        Task {
            do {
                try await projectRepository.save(newProject)
                try await sessionRepository.save(newSession)
            } catch {
                status = "Persistence error: \(error.localizedDescription)"
            }
        }
    }

    func captureAndReloadPoint() {
        guard var currentSession = session else {
            status = "Create a project first."
            return
        }
        let providers = SurveyProviderSelection.providers(
            for: currentSession.mode,
            local: localProvider,
            vendor: vendorProvider
        )
        let context = SurveyCaptureContext(
            projectID: currentSession.projectID,
            sessionID: currentSession.id,
            position: NormalizedPoint(x: 0.5, y: 0.5)
        )

        Task {
            do {
                var batches: [MeasurementBatch] = []
                for provider in providers {
                    batches.append(try await provider.capture(context: context))
                }
                let point = SurveyPoint(
                    position: context.position,
                    notes: [SurveyNote(text: "Development capture")],
                    measurementBatches: batches
                )
                currentSession.points.append(point)
                try await sessionRepository.save(currentSession)
                session = try await sessionRepository.session(id: currentSession.id)
                status = "Captured and reloaded \(batches.count) provider batch(es)."
            } catch {
                status = "Capture error: \(error.localizedDescription)"
            }
        }
    }
}

struct DomainProviderDevelopmentView: View {
    @StateObject private var model = DomainProviderDevelopmentModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Survey mode") {
                    Picker("Mode", selection: modeBinding) {
                        ForEach(SurveyMode.allCases, id: \.self) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    Button("Create \(model.mode.title) Project") {
                        model.createProject()
                    }
                }

                Section("Enabled providers") {
                    ForEach(model.capabilities.providers) { capability in
                        VStack(alignment: .leading) {
                            Text(capability.displayName).font(.headline)
                            Text(capability.supportedMeasurements.map(\.rawValue).sorted().joined(separator: ", "))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Persistence demonstration") {
                    Button("Capture Mock Point and Reload") {
                        model.captureAndReloadPoint()
                    }
                    .disabled(model.session == nil)
                    LabeledContent("Stored points", value: "\(model.session?.points.count ?? 0)")
                    Text(model.status).font(.caption).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Provider Architecture")
        }
    }

    private var modeBinding: Binding<SurveyMode> {
        Binding(get: { model.mode }, set: model.select)
    }
}

private extension SurveyMode {
    var title: String {
        switch self {
        case .general: "General"
        case .vendorAssisted: "Mist-Assisted"
        case .hybrid: "Hybrid"
        }
    }
}
