import Foundation
import Testing

@MainActor
struct SettingsSnapshotTests {
    private func json(_ text: String) -> Data {
        Data(text.utf8)
    }

    @Test func roundTripCarriesEverySetting() throws {
        let source = AppSettings(store: MemoryStore())
        source.isEnabled = false
        source.radius = 33
        source.corners = .right
        source.shortcutsEnabled = false
        source.autoClosesPopover = false
        source.hidesMenuBarIcon = true

        let data = try SettingsSnapshot(source).data()
        let target = AppSettings(store: MemoryStore())
        try SettingsSnapshot.read(data).apply(to: target)

        #expect(!target.isEnabled)
        #expect(target.radius == 33)
        #expect(target.corners == .right)
        #expect(!target.shortcutsEnabled)
        #expect(!target.autoClosesPopover)
        #expect(target.hidesMenuBarIcon)
    }

    @Test func pauseAndWelcomeStayOnThisMac() throws {
        let source = AppSettings(store: MemoryStore())
        source.pause(until: .now.addingTimeInterval(600))
        source.hasSeenWelcome = true

        let target = AppSettings(store: MemoryStore())
        try SettingsSnapshot.read(SettingsSnapshot(source).data()).apply(to: target)

        #expect(target.pausedUntil == nil)
        #expect(!target.hasSeenWelcome)
    }

    @Test func fileWithFewSettingsChangesOnlyThose() throws {
        let settings = AppSettings(store: MemoryStore())
        settings.corners = .left
        try SettingsSnapshot.read(json(#"{"app": "RoundedCorners", "format": 1, "radius": 20}"#)).apply(to: settings)

        #expect(settings.radius == 20)
        #expect(settings.corners == .left)
        #expect(settings.isEnabled)
    }

    @Test(arguments: [(100.0, 40.0), (1, 8), (22.6, 23)])
    func radiusIsKeptInRange(radius: Double, expected: Double) throws {
        let settings = AppSettings(store: MemoryStore())
        try SettingsSnapshot.read(json(#"{"app": "RoundedCorners", "format": 1, "radius": \#(radius)}"#)).apply(to: settings)
        #expect(settings.radius == expected)
    }

    @Test func unknownCornerChoiceIsSkipped() throws {
        let settings = AppSettings(store: MemoryStore())
        settings.corners = .left
        try SettingsSnapshot.read(json(#"{"app": "RoundedCorners", "format": 1, "corners": "top"}"#)).apply(to: settings)
        #expect(settings.corners == .left)
    }

    @Test(arguments: [
        "",
        "bukan json",
        "[]",
        #"{"format": 1, "radius": 20}"#,
        #"{"app": "AppLain", "format": 1}"#,
        #"{"app": "RoundedCorners", "format": 1, "radius": "besar"}"#,
    ])
    func rejectsOtherFiles(text: String) {
        #expect(throws: SettingsSnapshot.ReadError.notSettings) {
            try SettingsSnapshot.read(json(text))
        }
    }

    @Test func rejectsNewerFormat() {
        #expect(throws: SettingsSnapshot.ReadError.newerFormat) {
            try SettingsSnapshot.read(json(#"{"app": "RoundedCorners", "format": 2}"#))
        }
    }

    @Test func fileIsReadableJSON() throws {
        let settings = AppSettings(store: MemoryStore())
        let text = String(decoding: try SettingsSnapshot(settings).data(), as: UTF8.self)
        #expect(text.contains(#""app" : "RoundedCorners""#))
        #expect(text.contains(#""radius" : 28"#))
        #expect(text.contains("\n"))
    }
}
