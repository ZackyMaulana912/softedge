import AppKit

/// Temporary stage 1 menu bar item with only a Quit command.
@MainActor
final class StatusItemController {
    private var statusItem: NSStatusItem?

    func install() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = item.button {
            if let image = NSImage(systemSymbolName: "rectangle.roundedbottom", accessibilityDescription: "RoundedCorners") {
                image.isTemplate = true
                button.image = image
            } else {
                button.title = "RC"
            }
        }

        let menu = NSMenu()
        menu.addItem(withTitle: "Quit RoundedCorners", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        item.menu = menu

        statusItem = item
    }
}
