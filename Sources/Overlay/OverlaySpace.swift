import AppKit

/// A dedicated window server space shown above every desktop.
/// Windows inside it stay visible while swiping between desktops,
/// where normal all-spaces windows briefly disappear.
@MainActor
final class OverlaySpace {
    /// Set to false to compare with plain public API windows.
    static let isEnabled = true

    private static let absoluteLevel = Int32.max
    /// Must be 1, other values make Finder draw desktop icons into the space.
    private static let createFlag: Int32 = 1

    private let api: SkyLightAPI
    private let connection: Int32
    private let spaceID: UInt64

    init?() {
        guard let api = SkyLightAPI.load() else { return nil }
        let connection = api.mainConnectionID()
        let spaceID = api.spaceCreate(connection, Self.createFlag, nil)
        guard spaceID != 0 else { return nil }

        api.spaceSetAbsoluteLevel(connection, spaceID, Self.absoluteLevel)
        api.showSpaces(connection, [NSNumber(value: spaceID)] as CFArray)

        self.api = api
        self.connection = connection
        self.spaceID = spaceID
    }

    func add(_ windows: [NSWindow]) {
        api.addWindowsToSpaces(connection, windowIDs(windows), [NSNumber(value: spaceID)] as CFArray)
    }

    func remove(_ windows: [NSWindow]) {
        api.removeWindowsFromSpaces(connection, windowIDs(windows), [NSNumber(value: spaceID)] as CFArray)
    }

    private func windowIDs(_ windows: [NSWindow]) -> CFArray {
        windows.map { NSNumber(value: $0.windowNumber) } as CFArray
    }
}
