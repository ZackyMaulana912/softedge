import Foundation
import Observation

@MainActor
@Observable
final class AppSettings {
    static let radiusRange: ClosedRange<Double> = 8...40
    static let defaultRadius: Double = 28
    static let presets = [
        RadiusPreset(name: "Kecil", radius: 18),
        RadiusPreset(name: "Sedang", radius: defaultRadius),
        RadiusPreset(name: "Besar", radius: 38),
    ]

    private enum Key {
        static let isEnabled = "isEnabled"
        static let radius = "radius"
        static let hidesMenuBarIcon = "hidesMenuBarIcon"
        static let shortcutsEnabled = "shortcutsEnabled"
        static let pausedUntil = "pausedUntil"
        static let corners = "corners"
        static let autoClosesPopover = "autoClosesPopover"
        static let hasSeenWelcome = "hasSeenWelcome"
    }

    var isEnabled: Bool {
        didSet { store.set(isEnabled, forKey: Key.isEnabled) }
    }

    var radius: Double {
        didSet { store.set(radius, forKey: Key.radius) }
    }

    var hidesMenuBarIcon: Bool {
        didSet { store.set(hidesMenuBarIcon, forKey: Key.hidesMenuBarIcon) }
    }

    /// While set, the corners stay hidden even though the effect is on.
    /// Cleared by `PauseTimer` once the time has passed.
    var pausedUntil: Date? {
        didSet { store.set(pausedUntil, forKey: Key.pausedUntil) }
    }

    /// Whether the corners should be on screen right now.
    var showsCorners: Bool {
        isEnabled && pausedUntil == nil
    }

    var corners: CornerSelection {
        didSet { store.set(corners.rawValue, forKey: Key.corners) }
    }

    /// Close the settings popover once the pointer stays away for a moment.
    var autoClosesPopover: Bool {
        didSet { store.set(autoClosesPopover, forKey: Key.autoClosesPopover) }
    }

    var shortcutsEnabled: Bool {
        didSet { store.set(shortcutsEnabled, forKey: Key.shortcutsEnabled) }
    }

    /// False until the welcome card in the settings has been dismissed once.
    var hasSeenWelcome: Bool {
        didSet { store.set(hasSeenWelcome, forKey: Key.hasSeenWelcome) }
    }

    @ObservationIgnored private let store: SettingsStore

    init(store: SettingsStore = UserDefaults.standard) {
        self.store = store
        isEnabled = store.object(forKey: Key.isEnabled) as? Bool ?? true
        radius = (store.object(forKey: Key.radius) as? Double ?? Self.defaultRadius).clamped(to: Self.radiusRange)
        hidesMenuBarIcon = store.object(forKey: Key.hidesMenuBarIcon) as? Bool ?? false
        shortcutsEnabled = store.object(forKey: Key.shortcutsEnabled) as? Bool ?? true
        autoClosesPopover = store.object(forKey: Key.autoClosesPopover) as? Bool ?? true
        hasSeenWelcome = store.object(forKey: Key.hasSeenWelcome) as? Bool ?? false
        corners = (store.object(forKey: Key.corners) as? String).flatMap(CornerSelection.init(rawValue:)) ?? .both
        if let date = store.object(forKey: Key.pausedUntil) as? Date, date > .now {
            pausedUntil = date
        } else {
            pausedUntil = nil
        }
    }

    func pause(until date: Date) {
        isEnabled = true
        pausedUntil = date
    }

    func resume() {
        pausedUntil = nil
    }

    /// One action for every on/off control: ends a pause if there is one,
    /// otherwise flips the effect.
    func toggleCorners() {
        if pausedUntil != nil {
            pausedUntil = nil
            isEnabled = true
        } else {
            isEnabled.toggle()
        }
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
