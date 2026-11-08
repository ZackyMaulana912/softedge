import Foundation

/// Private SkyLight functions for managing window server spaces.
/// Resolved at runtime so a future macOS without them falls back instead of crashing.
struct SkyLightAPI {
    typealias MainConnectionID = @convention(c) () -> Int32
    typealias SpaceCreate = @convention(c) (Int32, Int32, CFDictionary?) -> UInt64
    typealias SpaceSetAbsoluteLevel = @convention(c) (Int32, UInt64, Int32) -> Void
    typealias ShowSpaces = @convention(c) (Int32, CFArray) -> Void
    typealias WindowsToSpaces = @convention(c) (Int32, CFArray, CFArray) -> Void

    let mainConnectionID: MainConnectionID
    let spaceCreate: SpaceCreate
    let spaceSetAbsoluteLevel: SpaceSetAbsoluteLevel
    let showSpaces: ShowSpaces
    let addWindowsToSpaces: WindowsToSpaces
    let removeWindowsFromSpaces: WindowsToSpaces

    static func load() -> SkyLightAPI? {
        guard let handle = dlopen("/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight", RTLD_NOW) else {
            return nil
        }

        func symbol<T>(_ name: String, as type: T.Type) -> T? {
            guard let pointer = dlsym(handle, name) else { return nil }
            return unsafeBitCast(pointer, to: type)
        }

        guard
            let mainConnectionID = symbol("CGSMainConnectionID", as: MainConnectionID.self),
            let spaceCreate = symbol("CGSSpaceCreate", as: SpaceCreate.self),
            let spaceSetAbsoluteLevel = symbol("CGSSpaceSetAbsoluteLevel", as: SpaceSetAbsoluteLevel.self),
            let showSpaces = symbol("CGSShowSpaces", as: ShowSpaces.self),
            let addWindowsToSpaces = symbol("CGSAddWindowsToSpaces", as: WindowsToSpaces.self),
            let removeWindowsFromSpaces = symbol("CGSRemoveWindowsFromSpaces", as: WindowsToSpaces.self)
        else {
            return nil
        }

        return SkyLightAPI(
            mainConnectionID: mainConnectionID,
            spaceCreate: spaceCreate,
            spaceSetAbsoluteLevel: spaceSetAbsoluteLevel,
            showSpaces: showSpaces,
            addWindowsToSpaces: addWindowsToSpaces,
            removeWindowsFromSpaces: removeWindowsFromSpaces
        )
    }
}
