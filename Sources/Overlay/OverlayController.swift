import AppKit

@MainActor
final class OverlayController {
    private let settings: AppSettings
    private var windows: [CornerPosition: CornerWindow] = [:]
    private let space: OverlaySpace? = OverlaySpace.isEnabled ? OverlaySpace() : nil

    init(settings: AppSettings) {
        self.settings = settings
    }

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
        observeChanges { [weak self] in
            guard let self else { return }
            self.update(enabled: self.settings.isEnabled, radius: self.settings.radius)
        }
    }

    @objc private func screensChanged(_ notification: Notification) {
        update(enabled: settings.isEnabled, radius: settings.radius)
    }

    private func update(enabled: Bool, radius: Double) {
        guard enabled, let screen = BuiltinScreen.find() else {
            if enabled {
                NSLog("RoundedCorners: built-in display not found, overlay not shown")
            }
            removeWindows()
            return
        }

        let style = CornerStyle.current
        let radius = CGFloat(radius)
        let size = style.extent(forRadius: radius)
        let frame = screen.frame

        for position in CornerPosition.allCases {
            let origin = NSPoint(
                x: position == .bottomLeft ? frame.minX : frame.maxX - size,
                y: frame.minY
            )
            let windowFrame = NSRect(origin: origin, size: NSSize(width: size, height: size))
            let window = windows[position] ?? makeWindow(position: position, frame: windowFrame, radius: radius, style: style)

            window.setFrame(windowFrame, display: false)
            (window.contentView as? CornerView)?.radius = radius
        }
    }

    private func makeWindow(position: CornerPosition, frame: NSRect, radius: CGFloat, style: CornerStyle) -> CornerWindow {
        let window = CornerWindow(frame: frame)
        window.contentView = CornerView(position: position, radius: radius, style: style)
        window.orderFrontRegardless()
        space?.add([window])
        windows[position] = window
        return window
    }

    private func removeWindows() {
        let all = Array(windows.values)
        space?.remove(all)
        all.forEach { $0.close() }
        windows.removeAll()
    }
}
