import Foundation

/// A dotted version number such as "0.1.1", compared part by part,
/// so "0.10.0" counts as newer than "0.9.0".
struct AppVersion: Comparable, Sendable, CustomStringConvertible {
    let parts: [Int]

    /// Accepts an optional leading "v", as used in the release tags.
    init?(_ text: String) {
        var trimmed = Substring(text.trimmingCharacters(in: .whitespaces))
        if trimmed.first == "v" || trimmed.first == "V" {
            trimmed = trimmed.dropFirst()
        }
        var parts: [Int] = []
        for piece in trimmed.split(separator: ".", omittingEmptySubsequences: false) {
            guard let number = Int(piece), number >= 0 else { return nil }
            parts.append(number)
        }
        guard !parts.isEmpty else { return nil }
        self.parts = parts
    }

    /// The version of the running app.
    static var current: AppVersion? {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String).flatMap(AppVersion.init)
    }

    var description: String {
        parts.map(String.init).joined(separator: ".")
    }

    /// Missing parts count as zero, so "0.2" equals "0.2.0".
    private static func padded(_ a: AppVersion, _ b: AppVersion) -> ([Int], [Int]) {
        let count = max(a.parts.count, b.parts.count)
        let pad = { (parts: [Int]) in parts + Array(repeating: 0, count: count - parts.count) }
        return (pad(a.parts), pad(b.parts))
    }

    static func == (lhs: AppVersion, rhs: AppVersion) -> Bool {
        let (a, b) = padded(lhs, rhs)
        return a == b
    }

    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        let (a, b) = padded(lhs, rhs)
        return a.lexicographicallyPrecedes(b)
    }
}
