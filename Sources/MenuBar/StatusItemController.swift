import AppKit
import SwiftUI

@MainActor
final class StatusItemController: NSObject, NSPopoverDelegate {
    private let settings: AppSettings
    private let status: OverlayStatus
    private let hud: HUDWindow
    private var statusItem: NSStatusItem?
    private let popover = NSPopover()
    private let autoClose = PopoverAutoClose()

    init(settings: AppSettings, status: OverlayStatus, hud: HUDWindow) {
        self.settings = settings
        self.status = status
        self.hud = hud
        super.init()
    }

    func install() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.target = self
        item.button?.action = #selector(buttonClicked(_:))
        item.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusItem = item

        let host = NSHostingController(rootView: SettingsView(settings: settings, status: status, onQuit: { NSApp.terminate(nil) }))
        host.sizingOptions = .preferredContentSize
        popover.contentViewController = host
        popover.behavior = .transient
        popover.delegate = self

        observeChanges { [weak self] in
            guard let self else { return }
            self.updateIcon()
            self.updateVisibility()
        }
    }

    /// Opens the settings even when the menu bar icon is hidden,
    /// by showing the icon until the popover closes again.
    func showSettings() {
        guard let item = statusItem, !popover.isShown else { return }
        item.isVisible = true
        Task { @MainActor in
            await self.waitUntilButtonIsPlaced()
            self.openPopover()
        }
    }

    /// For the keyboard shortcut: close the settings when open, otherwise open them.
    func toggleSettings() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            // Unlike a reopen from Spotlight, a shortcut does not activate the app,
            // and a hidden status item only gets placed for the active app.
            NSApp.activate()
            showSettings()
        }
    }

    /// A status item that was just made visible has no position yet, then slides
    /// down into the menu bar. Anchoring the popover before it settles puts the
    /// popover in the wrong place or fails to show it at all.
    private func waitUntilButtonIsPlaced() async {
        var previous: NSRect?
        for _ in 0..<40 {
            if let window = statusItem?.button?.window, let screen = window.screen {
                let frame = window.frame
                let atTop = frame.maxY >= screen.frame.maxY - 0.5
                if atTop && frame == previous {
                    return
                }
                previous = frame
            }
            try? await Task.sleep(for: .milliseconds(25))
        }
        NSLog("RoundedCorners: menu bar button was not placed in time, showing settings anyway")
    }

    func popoverDidClose(_ notification: Notification) {
        autoClose.stop()
        updateVisibility()
    }

    /// Left click opens the settings, right click (or Control click) flips the
    /// effect on or off without opening anything.
    @objc private func buttonClicked(_ sender: Any?) {
        if let event = NSApp.currentEvent,
           event.type == .rightMouseUp || event.modifierFlags.contains(.control) {
            settings.toggleCorners()
            hud.showCorners(enabled: settings.showsCorners)
            return
        }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            openPopover()
        }
    }

    private func openPopover() {
        guard let button = statusItem?.button else { return }
        NSApp.activate()
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        autoClose.start(popover: popover, anchor: button)
    }

    private func updateVisibility() {
        statusItem?.isVisible = !settings.hidesMenuBarIcon || popover.isShown
    }

    private func updateIcon() {
        guard let button = statusItem?.button else { return }
        let name: String
        let description: String

        if let until = settings.pausedUntil {
            let time = PauseSchedule.label(for: until)
            name = "pause.rectangle"
            description = "Sudut melengkung dijeda sampai \(time)"
            button.toolTip = "RoundedCorners: dijeda sampai \(time)\nKlik kanan untuk melanjutkan"
        } else if settings.isEnabled {
            name = "rectangle.roundedbottom"
            description = "Sudut melengkung nyala"
            button.toolTip = "RoundedCorners: nyala\nKlik kanan untuk mematikan"
        } else {
            name = "rectangle"
            description = "Sudut melengkung mati"
            button.toolTip = "RoundedCorners: mati\nKlik kanan untuk menyalakan"
        }

        if let image = NSImage(systemSymbolName: name, accessibilityDescription: description) {
            image.isTemplate = true
            button.image = image
            button.title = ""
        } else {
            button.image = nil
            button.title = "RC"
        }
    }
}
