import Foundation
#if canImport(Darwin)
import Darwin
#endif

struct DiagnosticResult: Identifiable { let id = UUID(); let title: String; let detail: String; let success: Bool }

enum NetworkProbe {
    static func dns(host: String) async -> DiagnosticResult {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var hints = addrinfo(ai_flags: AI_DEFAULT, ai_family: AF_UNSPEC, ai_socktype: SOCK_STREAM, ai_protocol: 0, ai_addrlen: 0, ai_canonname: nil, ai_addr: nil, ai_next: nil)
                var result: UnsafeMutablePointer<addrinfo>?
                let code = getaddrinfo(host, nil, &hints, &result)
                defer { if result != nil { freeaddrinfo(result) } }
                guard code == 0 else { continuation.resume(returning: .init(title: "DNS", detail: String(cString: gai_strerror(code)), success: false)); return }
                var addresses: [String] = []; var cursor = result
                while let item = cursor {
                    var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(item.pointee.ai_addr, item.pointee.ai_addrlen, &hostBuffer, socklen_t(hostBuffer.count), nil, 0, NI_NUMERICHOST) == 0 { addresses.append(String(cString: hostBuffer)) }
                    cursor = item.pointee.ai_next
                }
                continuation.resume(returning: .init(title: "DNS", detail: Array(Set(addresses)).sorted().joined(separator: "\n"), success: !addresses.isEmpty))
            }
        }
    }

    static func httpsPing(host: String, count: Int = 4) async -> DiagnosticResult {
        guard let url = URL(string: host.hasPrefix("http") ? host : "https://\(host)") else { return .init(title: "HTTPS Ping", detail: "Invalid host", success: false) }
        var times: [Double] = []; var lost = 0
        for _ in 0..<count { let start = Date(); do { var request = URLRequest(url: url); request.timeoutInterval = 8; _ = try await URLSession.shared.data(for: request); times.append(Date().timeIntervalSince(start) * 1000) } catch { lost += 1 } }
        let average = times.isEmpty ? 0 : times.reduce(0,+) / Double(times.count)
        return .init(title: "HTTPS Ping", detail: String(format: "avg %.1f ms • loss %.0f%%", average, Double(lost)/Double(count)*100), success: !times.isEmpty)
    }

    static func traceroute(host: String) async -> DiagnosticResult {
        #if os(macOS)
        return await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                let process = Process(); let pipe = Pipe(); process.executableURL = URL(fileURLWithPath: "/usr/sbin/traceroute"); process.arguments = ["-m", "12", "-w", "1", host]; process.standardOutput = pipe; process.standardError = pipe
                do { try process.run(); process.waitUntilExit(); let data = pipe.fileHandleForReading.readDataToEndOfFile(); continuation.resume(returning: .init(title: "Traceroute", detail: String(data: data, encoding: .utf8) ?? "No output", success: process.terminationStatus == 0)) } catch { continuation.resume(returning: .init(title: "Traceroute", detail: error.localizedDescription, success: false)) }
            }
        }
        #else
        return .init(title: "Traceroute", detail: "Hop discovery is available in the macOS build. iOS public APIs do not expose raw TTL probing.", success: false)
        #endif
    }
}
