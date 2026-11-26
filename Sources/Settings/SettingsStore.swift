import Foundation

/// The little the settings need from a key-value store. The app keeps its
/// settings in `UserDefaults`, the tests in memory so they never touch real ones.
protocol SettingsStore: AnyObject {
    func object(forKey key: String) -> Any?
    func set(_ value: Any?, forKey key: String)
}

extension UserDefaults: SettingsStore {}
