import AppKit
import SwiftUI

@MainActor
final class StatusItemController: NSObject, NSPopoverDelegate {
    private let settings: AppSettings
    private var statusItem: NSStatusItem?
    private let popover = NSPopover()

    init(settings: AppSettings) {
        self.settings = settings
        super.init()
    }

    func install() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.target = self
        item.button?.action = #selector(togglePopover(_:))
        statusItem = item

        let host = NSHostingController(rootView: SettingsView(settings: settings, onQuit: { NSApp.terminate(nil) }))
        host.sizingOptions = .preferredContentSize
        popover.contentViewController = host
        popover.behavior = .transient
        popover.delegate = self

        observeChanges { [weak self] in
            guard let self else { return }
            self.updateIcon(enabled: self.settings.isEnabled)
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
        updateVisibility()
    }

    @objc private func togglePopover(_ sender: Any?) {
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
    }

    private func updateVisibility() {
        statusItem?.isVisible = !settings.hidesMenuBarIcon || popover.isShown
    }

    private func updateIcon(enabled: Bool) {
        guard let button = statusItem?.button else { return }
        let name = enabled ? "rectangle.roundedbottom" : "rectangle"
        let description = enabled ? "Rounded corners on" : "Rounded corners off"

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
