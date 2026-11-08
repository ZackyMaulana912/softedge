import AppKit

@MainActor
final class CornerView: NSView {
    private let position: CornerPosition
    private let radius: CGFloat
    private let style: CornerStyle

    init(frame: NSRect, position: CornerPosition, radius: CGFloat, style: CornerStyle) {
        self.position = position
        self.radius = radius
        self.style = style
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override var isOpaque: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        let visible = CornerPath.visibleArea(
            size: bounds.width,
            radius: radius,
            style: style,
            position: position
        )

        // Fill everything black, then cut out the inside of the curve with even-odd.
        context.addRect(bounds)
        context.addPath(visible)
        context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        context.fillPath(using: .evenOdd)
    }
}
