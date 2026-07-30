import Foundation

enum RepositoryError: Error, Equatable {
    case unsupportedSchemaVersion(found: Int, supported: Int)
}

protocol ProjectRepository: Sendable {
    func save(_ project: RFProject) async throws
    func project(id: UUID) async throws -> RFProject?
    func allProjects() async throws -> [RFProject]
}

protocol SurveySessionRepository: Sendable {
    func save(_ session: SurveySession) async throws
    func session(id: UUID) async throws -> SurveySession?
    func sessions(projectID: UUID) async throws -> [SurveySession]
}

private struct RepositoryEnvelope<Value: Codable & Sendable>: Codable, Sendable {
    let schemaVersion: Int
    var values: [Value]
}

actor LocalJSONProjectRepository: ProjectRepository {
    private let fileURL: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(directory: URL, fileManager: FileManager = .default) {
        self.fileURL = directory.appendingPathComponent("projects.json")
        self.fileManager = fileManager
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func save(_ project: RFProject) throws {
        var projects = try load()
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
        } else {
            projects.append(project)
        }
        try persist(projects)
    }

    func project(id: UUID) throws -> RFProject? {
        try load().first { $0.id == id }
    }

    func allProjects() throws -> [RFProject] {
        try load()
    }

    private func load() throws -> [RFProject] {
        guard fileManager.fileExists(atPath: fileURL.path) else { return [] }
        let envelope = try decoder.decode(
            RepositoryEnvelope<RFProject>.self,
            from: Data(contentsOf: fileURL)
        )
        guard envelope.schemaVersion == RFProject.currentSchemaVersion else {
            throw RepositoryError.unsupportedSchemaVersion(
                found: envelope.schemaVersion,
                supported: RFProject.currentSchemaVersion
            )
        }
        return envelope.values
    }

    private func persist(_ projects: [RFProject]) throws {
        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let envelope = RepositoryEnvelope(
            schemaVersion: RFProject.currentSchemaVersion,
            values: projects
        )
        try encoder.encode(envelope).write(to: fileURL, options: .atomic)
    }
}

actor LocalJSONSurveySessionRepository: SurveySessionRepository {
    private let fileURL: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(directory: URL, fileManager: FileManager = .default) {
        self.fileURL = directory.appendingPathComponent("sessions.json")
        self.fileManager = fileManager
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func save(_ session: SurveySession) throws {
        var sessions = try load()
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        } else {
            sessions.append(session)
        }
        try persist(sessions)
    }

    func session(id: UUID) throws -> SurveySession? {
        try load().first { $0.id == id }
    }

    func sessions(projectID: UUID) throws -> [SurveySession] {
        try load().filter { $0.projectID == projectID }
    }

    private func load() throws -> [SurveySession] {
        guard fileManager.fileExists(atPath: fileURL.path) else { return [] }
        let envelope = try decoder.decode(
            RepositoryEnvelope<SurveySession>.self,
            from: Data(contentsOf: fileURL)
        )
        guard envelope.schemaVersion == RFProject.currentSchemaVersion else {
            throw RepositoryError.unsupportedSchemaVersion(
                found: envelope.schemaVersion,
                supported: RFProject.currentSchemaVersion
            )
        }
        return envelope.values
    }

    private func persist(_ sessions: [SurveySession]) throws {
        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let envelope = RepositoryEnvelope(
            schemaVersion: RFProject.currentSchemaVersion,
            values: sessions
        )
        try encoder.encode(envelope).write(to: fileURL, options: .atomic)
    }
}
