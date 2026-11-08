import AppKit

/// Closes the popover once the pointer has stayed away from it for a while.
/// Counting only starts after the pointer has been over the popover or the
/// menu bar icon, so a popover opened from Spotlight does not vanish on its own.
@MainActor
final class PopoverAutoClose {
    static let delay: Duration = .seconds(2)
    private static let pollInterval: Duration = .milliseconds(200)
    private static let margin: CGFloat = 8

    private var task: Task<Void, Never>?

    func start(popover: NSPopover, anchor: NSView) {
        stop()
        task = Task { @MainActor [weak popover, weak anchor] in
            var hasBeenInside = false
            var awaySince: ContinuousClock.Instant?

            while !Task.isCancelled {
                try? await Task.sleep(for: Self.pollInterval)
                guard let popover, popover.isShown else { return }

                let inside = Self.isPointer(over: popover, or: anchor)
                // A held button means a drag (for example the slider), never close mid-drag.
                if inside || NSEvent.pressedMouseButtons != 0 {
                    hasBeenInside = hasBeenInside || inside
                    awaySince = nil
                    continue
                }
                guard hasBeenInside else { continue }

                let since = awaySince ?? ContinuousClock.now
                awaySince = since
                if ContinuousClock.now - since >= Self.delay {
                    popover.performClose(nil)
                    return
                }
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }

    private static func isPointer(over popover: NSPopover, or anchor: NSView?) -> Bool {
        let point = NSEvent.mouseLocation
        if let frame = popover.contentViewController?.view.window?.frame,
           frame.insetBy(dx: -margin, dy: -margin).contains(point) {
            return true
        }
        if let anchor, let window = anchor.window {
            let rect = window.convertToScreen(anchor.convert(anchor.bounds, to: nil))
            if rect.insetBy(dx: -margin, dy: -margin).contains(point) {
                return true
            }
        }
        return false
    }
}
