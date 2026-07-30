import Foundation

@MainActor
final class MeasurementStore: ObservableObject {
    @Published var projects: [SurveyProject] = [] { didSet { saveProjects() } }
    @Published var selectedProjectID: UUID? { didSet { UserDefaults.standard.set(selectedProjectID?.uuidString, forKey: "selectedProjectID") } }
    @Published var mistConfiguration = MistConfiguration() { didSet { saveMist() } }
    @Published var sites: [MistSite] = []
    @Published var devices: [MistDevice] = []
    @Published var liveRF: RFReading?
    @Published var isBusy = false
    @Published var message: String?

    private let projectsURL: URL
    private let mistURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        projectsURL = dir.appendingPathComponent("rfvision-enterprise-projects.json")
        mistURL = dir.appendingPathComponent("rfvision-enterprise-mist.json")
        load()
    }

    var selectedProject: SurveyProject? {
        guard let id = selectedProjectID else { return nil }
        return projects.first { $0.id == id }
    }

    func createProject(name: String) {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let project = SurveyProject(name: clean.isEmpty ? "New Survey" : clean, siteID: mistConfiguration.defaultSiteID, clientMAC: "")
        projects.insert(project, at: 0)
        selectedProjectID = project.id
    }

    func updateProject(_ project: SurveyProject) {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else { return }
        var value = project; value.modifiedAt = Date(); projects[index] = value
    }

    func deleteProject(id: UUID) {
        projects.removeAll { $0.id == id }
        if selectedProjectID == id { selectedProjectID = projects.first?.id }
    }

    func addPoint(_ point: SurveyPoint, to projectID: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == projectID }) else { return }
        projects[index].points.append(point); projects[index].modifiedAt = Date()
    }

    func exportProject(_ project: SurveyProject) throws -> URL {
        let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]; encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(project)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(project.name.replacingOccurrences(of: " ", with: "-"))-RFVision.json")
        try data.write(to: url, options: .atomic); return url
    }

    private func load() {
        if let data = try? Data(contentsOf: projectsURL), let decoded = try? JSONDecoder().decode([SurveyProject].self, from: data) { projects = decoded }
        if let data = try? Data(contentsOf: mistURL), let decoded = try? JSONDecoder().decode(MistConfiguration.self, from: data) { mistConfiguration = decoded }
        if let raw = UserDefaults.standard.string(forKey: "selectedProjectID"), let id = UUID(uuidString: raw) { selectedProjectID = id }
        if selectedProjectID == nil { selectedProjectID = projects.first?.id }
    }

    private func saveProjects() { if let data = try? JSONEncoder().encode(projects) { try? data.write(to: projectsURL, options: .atomic) } }
    private func saveMist() { if let data = try? JSONEncoder().encode(mistConfiguration) { try? data.write(to: mistURL, options: .atomic) } }
}
