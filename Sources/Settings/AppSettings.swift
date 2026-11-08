import Foundation
import Observation

@MainActor
@Observable
final class AppSettings {
    static let radiusRange: ClosedRange<Double> = 8...40
    static let defaultRadius: Double = 28

    private enum Key {
        static let isEnabled = "isEnabled"
        static let radius = "radius"
        static let hidesMenuBarIcon = "hidesMenuBarIcon"
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

    init() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            Key.isEnabled: true,
            Key.radius: Self.defaultRadius,
            Key.hidesMenuBarIcon: false,
        ])

        isEnabled = defaults.bool(forKey: Key.isEnabled)
        radius = defaults.double(forKey: Key.radius).clamped(to: Self.radiusRange)
        hidesMenuBarIcon = defaults.bool(forKey: Key.hidesMenuBarIcon)
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
