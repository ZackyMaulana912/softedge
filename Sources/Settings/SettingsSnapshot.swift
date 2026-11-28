import Foundation

/// The settings worth carrying to another Mac, saved as a small JSON file.
/// A pause, the welcome, and launch at login stay behind: they belong to this Mac.
/// Every setting is optional, so a file that names only a few changes only those.
struct SettingsSnapshot: Codable, Equatable, Sendable {
    static let appName = "RoundedCorners"
    static let currentFormat = 1

    /// Marks the file as ours, and lets a later version change the format.
    var app = appName
    var format = currentFormat

    var isEnabled: Bool?
    var radius: Double?
    var corners: String?
    var shortcutsEnabled: Bool?
    var autoClosesPopover: Bool?
    var hidesMenuBarIcon: Bool?

    enum ReadError: LocalizedError, Equatable {
        case notSettings
        case newerFormat

        var errorDescription: String? {
            switch self {
            case .notSettings: return "File ini bukan pengaturan RoundedCorners."
            case .newerFormat: return "File ini dibuat versi RoundedCorners yang lebih baru. Perbarui app dulu."
            }
        }
    }

    init() {}

    @MainActor
    init(_ settings: AppSettings) {
        isEnabled = settings.isEnabled
        radius = settings.radius
        corners = settings.corners.rawValue
        shortcutsEnabled = settings.shortcutsEnabled
        autoClosesPopover = settings.autoClosesPopover
        hidesMenuBarIcon = settings.hidesMenuBarIcon
    }

    static func read(_ data: Data) throws -> SettingsSnapshot {
        guard let snapshot = try? JSONDecoder().decode(SettingsSnapshot.self, from: data),
              snapshot.app == appName else {
            throw ReadError.notSettings
        }
        guard snapshot.format <= currentFormat else {
            throw ReadError.newerFormat
        }
        return snapshot
    }

    func data() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(self)
    }

    /// Values out of range are pulled back in, unknown ones are skipped.
    @MainActor
    func apply(to settings: AppSettings) {
        if let isEnabled { settings.isEnabled = isEnabled }
        if let radius, radius.isFinite {
            let range = AppSettings.radiusRange
            settings.radius = min(max(radius.rounded(), range.lowerBound), range.upperBound)
        }
        if let corners, let selection = CornerSelection(rawValue: corners) {
            settings.corners = selection
        }
        if let shortcutsEnabled { settings.shortcutsEnabled = shortcutsEnabled }
        if let autoClosesPopover { settings.autoClosesPopover = autoClosesPopover }
        if let hidesMenuBarIcon { settings.hidesMenuBarIcon = hidesMenuBarIcon }
    }
}
