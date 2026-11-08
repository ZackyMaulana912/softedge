import AppKit

@MainActor
final class OverlayController {
    private var windows: [CornerWindow] = []
    private let space: OverlaySpace? = OverlaySpace.isEnabled ? OverlaySpace() : nil

    func start() {
        if OverlaySpace.isEnabled && space == nil {
            NSLog("RoundedCorners: dedicated space unavailable, corners may flicker when switching desktops")
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
        rebuild()
    }

    @objc private func screensChanged(_ notification: Notification) {
        rebuild()
    }

    private func rebuild() {
        space?.remove(windows)
        windows.forEach { $0.close() }
        windows.removeAll()

        guard let screen = BuiltinScreen.find() else {
            NSLog("RoundedCorners: built-in display not found, overlay not shown")
            return
        }

        let style = CornerStyle.current
        let radius = CornerStyle.radius
        let size = style.extent(forRadius: radius)
        let frame = screen.frame

        for position in CornerPosition.allCases {
            let origin = NSPoint(
                x: position == .bottomLeft ? frame.minX : frame.maxX - size,
                y: frame.minY
            )
            let window = CornerWindow(frame: NSRect(origin: origin, size: NSSize(width: size, height: size)))
            window.contentView = CornerView(
                frame: NSRect(x: 0, y: 0, width: size, height: size),
                position: position,
                radius: radius,
                style: style
            )
            window.orderFrontRegardless()
            windows.append(window)
        }

        space?.add(windows)
    }
}
