import AppKit
import SwiftUI

/// Small notice near the bottom of the screen, like the system volume HUD.
/// Used when a change happens without the settings being open.
@MainActor
final class HUDWindow {
    private static let visibleFor: Duration = .seconds(1.2)
    private static let bottomOffset: CGFloat = 140

    private let panel: NSPanel
    private let host = NSHostingView(rootView: HUDView(symbol: "circle", text: ""))
    private var hideTask: Task<Void, Never>?

    init() {
        panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.ignoresMouseEvents = true
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        panel.isReleasedWhenClosed = false
        panel.animationBehavior = .none
        panel.contentView = host
    }

    func show(symbol: String, text: String) {
        host.rootView = HUDView(symbol: symbol, text: text)
        let size = host.fittingSize

        // The screen with the pointer is where the person is looking.
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { $0.frame.contains(mouse) } ?? NSScreen.main
        guard let frame = screen?.visibleFrame else { return }
        panel.setFrame(NSRect(
            x: frame.midX - size.width / 2,
            y: frame.minY + Self.bottomOffset,
            width: size.width,
            height: size.height
        ), display: true)

        panel.alphaValue = 1
        panel.orderFrontRegardless()

        hideTask?.cancel()
        hideTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: Self.visibleFor)
            guard !Task.isCancelled, let self else { return }
            await NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                self.panel.animator().alphaValue = 0
            }
            guard !Task.isCancelled else { return }
            self.panel.orderOut(nil)
        }
    }
}
