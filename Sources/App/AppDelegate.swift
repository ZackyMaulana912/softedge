import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings: AppSettings
    private let overlay: OverlayController
    private let statusItem: StatusItemController

    override init() {
        settings = AppSettings()
        overlay = OverlayController(settings: settings)
        statusItem = StatusItemController(settings: settings)
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem.install()
        overlay.start()

        // With the icon hidden, a manual launch would otherwise show nothing at all.
        // A launch at login stays silent, so only do this when that option is off.
        if settings.hidesMenuBarIcon && !LaunchAtLogin.isEnabled {
            statusItem.showSettings()
        }
    }

    /// Opening the app again (Spotlight, Launchpad, Finder) brings up the settings,
    /// which is the only way back when the menu bar icon is hidden.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        statusItem.showSettings()
        return false
    }
}
