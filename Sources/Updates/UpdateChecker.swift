import Foundation
import Observation

/// Asks GitHub for the newest release and compares it with the running app.
/// Runs only when the user asks for it, nothing is checked in the background.
@MainActor
@Observable
final class UpdateChecker {
    enum State: Equatable {
        case idle
        case checking
        case upToDate
        case available(version: String, page: URL)
        case failed(String)
    }

    private(set) var state: State = .idle

    private nonisolated static let latestReleaseAPI = URL(string: "https://api.github.com/repos/ZackyMaulana912/softedge/releases/latest")!

    func check() async {
        guard state != .checking else { return }
        state = .checking
        do {
            let release = try await Self.fetchLatestRelease()
            guard let latest = AppVersion(release.tagName), let current = AppVersion.current else {
                state = .failed("Nomor versi tidak terbaca")
                return
            }
            state = latest > current
                ? .available(version: latest.description, page: release.htmlURL)
                : .upToDate
        } catch {
            NSLog("RoundedCorners: update check failed: %@", String(describing: error))
            state = .failed(Self.message(for: error))
        }
    }

    private struct Release: Decodable, Sendable {
        let tagName: String
        let htmlURL: URL

        enum CodingKeys: String, CodingKey {
            case tagName = "tag_name"
            case htmlURL = "html_url"
        }
    }

    private enum CheckError: Error {
        case status(Int)
    }

    private nonisolated static func fetchLatestRelease() async throws -> Release {
        var request = URLRequest(url: latestReleaseAPI, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard status == 200 else { throw CheckError.status(status) }
        return try JSONDecoder().decode(Release.self, from: data)
    }

    private static func message(for error: Error) -> String {
        switch error {
        case let error as URLError where error.code == .notConnectedToInternet || error.code == .networkConnectionLost:
            return "Tidak ada koneksi internet"
        case let error as URLError where error.code == .timedOut:
            return "GitHub tidak menjawab"
        case CheckError.status(404):
            return "Belum ada rilis di GitHub"
        // GitHub allows 60 requests per hour without signing in.
        case CheckError.status(403), CheckError.status(429):
            return "Terlalu sering, coba lagi nanti"
        case CheckError.status(let code) where (500...599).contains(code):
            return "GitHub sedang gangguan"
        default:
            return "Gagal memeriksa"
        }
    }
}
