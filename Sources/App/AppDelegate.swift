import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings: AppSettings
    private let status: OverlayStatus
    private let overlay: OverlayController
    private let statusItem: StatusItemController
    private let hotKeys = GlobalHotKeys()
    private let pauseTimer: PauseTimer
    private let hud: HUDWindow

    override init() {
        settings = AppSettings()
        status = OverlayStatus()
        hud = HUDWindow()
        pauseTimer = PauseTimer(settings: settings)
        overlay = OverlayController(settings: settings, status: status)
        statusItem = StatusItemController(settings: settings, status: status, hud: hud)
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem.install()
        overlay.start()
        pauseTimer.start()
        observeChanges { [weak self] in
            guard let self else { return }
            if self.settings.shortcutsEnabled {
                self.hotKeys.register(AppShortcut.allCases) { [weak self] shortcut in
                    self?.handle(shortcut)
                }
            } else {
                self.hotKeys.unregister()
            }
        }

        // The very first launch shows the welcome, so a new user sees where the app lives.
        // With the icon hidden, a manual launch would otherwise show nothing at all.
        // A launch at login stays silent, so only do this when that option is off.
        if !settings.hasSeenWelcome || (settings.hidesMenuBarIcon && !LaunchAtLogin.isEnabled) {
            statusItem.showSettings()
        }
    }

    private func handle(_ shortcut: AppShortcut) {
        switch shortcut {
        case .toggle:
            settings.toggleCorners()
            hud.showCorners(enabled: settings.showsCorners)
        case .settings:
            statusItem.toggleSettings()
        case .radiusUp:
            changeRadius(by: 1)
        case .radiusDown:
            changeRadius(by: -1)
        }
    }

    private func changeRadius(by step: Double) {
        guard settings.isEnabled else { return }
        let range = AppSettings.radiusRange
        settings.radius = min(max(settings.radius + step, range.lowerBound), range.upperBound)
        hud.showRadius(settings.radius)
    }

    /// Opening the app again (Spotlight, Launchpad, Finder) brings up the settings,
    /// which is the only way back when the menu bar icon is hidden.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        statusItem.showSettings()
        return false
    }
}
