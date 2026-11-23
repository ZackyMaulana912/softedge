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
            self?.update()
        }
    }

    @objc private func screensChanged(_ notification: Notification) {
        update()
    }

    /// After sleep the window server can rebuild its window lists, so bring the
    /// corners back to the front and into the overlay space again.
    @objc private func systemWoke(_ notification: Notification) {
        update()
        let all = Array(windows.values)
        guard !all.isEmpty else { return }
        all.forEach { $0.orderFrontRegardless() }
        space?.add(all)
    }

    /// Reads every setting it depends on, so `observeChanges` reruns it on any change.
    private func update() {
        let enabled = settings.showsCorners
        let radius = CGFloat(settings.radius)
        let positions = settings.corners.positions

        let builtin = BuiltinScreen.find()
        status.hasBuiltinScreen = builtin != nil

        guard enabled, let screen = builtin else {
            if enabled {
                NSLog("RoundedCorners: built-in display not found, overlay not shown")
            }
            removeWindows(Set(windows.keys))
            return
        }
        removeWindows(Set(windows.keys).subtracting(positions))

        let style = CornerStyle.current
        let size = style.extent(forRadius: radius)
        let frame = screen.frame

        for position in CornerPosition.allCases where positions.contains(position) {
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

    private func removeWindows(_ positions: Set<CornerPosition>) {
        let removed = positions.compactMap { windows.removeValue(forKey: $0) }
        guard !removed.isEmpty else { return }
        space?.remove(removed)
        removed.forEach { $0.close() }
    }
}
