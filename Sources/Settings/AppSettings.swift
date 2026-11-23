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
        ])

        isEnabled = defaults.bool(forKey: Key.isEnabled)
        radius = defaults.double(forKey: Key.radius).clamped(to: Self.radiusRange)
        hidesMenuBarIcon = defaults.bool(forKey: Key.hidesMenuBarIcon)
        shortcutsEnabled = defaults.bool(forKey: Key.shortcutsEnabled)
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
