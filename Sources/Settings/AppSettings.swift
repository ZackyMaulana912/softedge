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
    }

    var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: Key.isEnabled) }
    }

    var radius: Double {
        didSet { UserDefaults.standard.set(radius, forKey: Key.radius) }
    }

    var hidesMenuBarIcon: Bool {
        didSet { UserDefaults.standard.set(hidesMenuBarIcon, forKey: Key.hidesMenuBarIcon) }
    }

    /// While set, the corners stay hidden even though the effect is on.
    /// Cleared by `PauseTimer` once the time has passed.
    var pausedUntil: Date? {
        didSet { UserDefaults.standard.set(pausedUntil, forKey: Key.pausedUntil) }
    }

    /// Whether the corners should be on screen right now.
    var showsCorners: Bool {
        isEnabled && pausedUntil == nil
    }

    var corners: CornerSelection {
        didSet { UserDefaults.standard.set(corners.rawValue, forKey: Key.corners) }
    }

    var shortcutsEnabled: Bool {
        didSet { UserDefaults.standard.set(shortcutsEnabled, forKey: Key.shortcutsEnabled) }
    }

    init() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            Key.isEnabled: true,
            Key.radius: Self.defaultRadius,
            Key.hidesMenuBarIcon: false,
            Key.shortcutsEnabled: true,
            Key.corners: CornerSelection.both.rawValue,
        ])

        isEnabled = defaults.bool(forKey: Key.isEnabled)
        radius = defaults.double(forKey: Key.radius).clamped(to: Self.radiusRange)
        hidesMenuBarIcon = defaults.bool(forKey: Key.hidesMenuBarIcon)
        shortcutsEnabled = defaults.bool(forKey: Key.shortcutsEnabled)
        corners = defaults.string(forKey: Key.corners).flatMap(CornerSelection.init(rawValue:)) ?? .both
        if let date = defaults.object(forKey: Key.pausedUntil) as? Date, date > .now {
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
