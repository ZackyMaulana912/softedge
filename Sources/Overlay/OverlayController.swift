import AppKit

@MainActor
final class OverlayController {
    private let settings: AppSettings
    private let status: OverlayStatus
    private var windows: [CornerPosition: CornerWindow] = [:]
    private let space: OverlaySpace? = OverlaySpace.isEnabled ? OverlaySpace() : nil

    init(settings: AppSettings, status: OverlayStatus) {
        self.settings = settings
        self.status = status
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
        let workspace = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.didWakeNotification, NSWorkspace.screensDidWakeNotification] {
            workspace.addObserver(self, selector: #selector(systemWoke), name: name, object: nil)
        }
        observeChanges { [weak self] in
            guard let self else { return }
            self.update(enabled: self.settings.showsCorners, radius: self.settings.radius)
        }
    }

    @objc private func screensChanged(_ notification: Notification) {
        update(enabled: settings.showsCorners, radius: settings.radius)
    }

    /// After sleep the window server can rebuild its window lists, so bring the
    /// corners back to the front and into the overlay space again.
    @objc private func systemWoke(_ notification: Notification) {
        update(enabled: settings.showsCorners, radius: settings.radius)
        let all = Array(windows.values)
        guard !all.isEmpty else { return }
        all.forEach { $0.orderFrontRegardless() }
        space?.add(all)
    }

    private func update(enabled: Bool, radius: Double) {
        let builtin = BuiltinScreen.find()
        status.hasBuiltinScreen = builtin != nil

        guard enabled, let screen = builtin else {
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
