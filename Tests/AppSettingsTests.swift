import Foundation
import Testing

@MainActor
struct AppSettingsTests {
    private func withStore(_ body: (MemoryStore) throws -> Void) rethrows {
        try body(MemoryStore())
    }

    @Test func freshInstallUsesDefaults() {
        withStore { store in
            let settings = AppSettings(store: store)
            #expect(settings.isEnabled)
            #expect(settings.radius == AppSettings.defaultRadius)
            #expect(settings.corners == .both)
            #expect(settings.shortcutsEnabled)
            #expect(settings.autoClosesPopover)
            #expect(!settings.hidesMenuBarIcon)
            #expect(!settings.hasSeenWelcome)
            #expect(settings.pausedUntil == nil)
            #expect(settings.showsCorners)
        }
    }

    @Test func changesSurviveARestart() {
        withStore { store in
            let first = AppSettings(store: store)
            first.radius = 20
            first.corners = .left
            first.hasSeenWelcome = true
            first.shortcutsEnabled = false

            let second = AppSettings(store: store)
            #expect(second.radius == 20)
            #expect(second.corners == .left)
            #expect(second.hasSeenWelcome)
            #expect(!second.shortcutsEnabled)
        }
    }

    @Test(arguments: [(100.0, 40.0), (2, 8), (-5, 8), (17, 17)])
    func storedRadiusIsKeptInRange(stored: Double, expected: Double) {
        withStore { store in
            store.values["radius"] = stored
            #expect(AppSettings(store: store).radius == expected)
        }
    }

    @Test func unknownCornerChoiceFallsBackToBoth() {
        withStore { store in
            store.values["corners"] = "top"
            #expect(AppSettings(store: store).corners == .both)
        }
    }

    @Test func pauseThatEndedWhileQuitIsDropped() {
        withStore { store in
            store.values["pausedUntil"] = Date.now.addingTimeInterval(-60)
            #expect(AppSettings(store: store).pausedUntil == nil)
        }
    }

    @Test func pauseStillRunningIsKept() {
        withStore { store in
            let end = Date.now.addingTimeInterval(600)
            store.values["pausedUntil"] = end
            let settings = AppSettings(store: store)
            #expect(settings.pausedUntil == end)
            #expect(!settings.showsCorners)
        }
    }

    @Test func pausingTurnsTheEffectOn() {
        withStore { store in
            let settings = AppSettings(store: store)
            settings.isEnabled = false
            settings.pause(until: .now.addingTimeInterval(600))
            #expect(settings.isEnabled)
            #expect(!settings.showsCorners)
        }
    }

    @Test func toggleWhilePausedResumes() {
        withStore { store in
            let settings = AppSettings(store: store)
            settings.pause(until: .now.addingTimeInterval(600))
            settings.toggleCorners()
            #expect(settings.pausedUntil == nil)
            #expect(settings.isEnabled)
            #expect(settings.showsCorners)
        }
    }

    @Test func toggleFlipsOnAndOff() {
        withStore { store in
            let settings = AppSettings(store: store)
            settings.toggleCorners()
            #expect(!settings.showsCorners)
            settings.toggleCorners()
            #expect(settings.showsCorners)
        }
    }
}
