import CoreGraphics
import Testing

/// The visible area is what stays transparent; everything else in the
/// corner window is painted black. Coordinates have the origin at the bottom left.
struct CornerShapeTests {
    private func visible(_ point: CGPoint, radius: CGFloat, style: CornerStyle, position: CornerPosition) -> Bool {
        let size = style.extent(forRadius: radius)
        let path = CornerPath.visibleArea(size: size, radius: radius, style: style, position: position)
        return path.contains(point)
    }

    @Test(arguments: [CornerStyle.continuous, .circular])
    func leftCornerIsBlackAtTheScreenCorner(style: CornerStyle) {
        let size = style.extent(forRadius: 28)
        #expect(!visible(CGPoint(x: 0.5, y: 0.5), radius: 28, style: style, position: .bottomLeft))
        #expect(visible(CGPoint(x: size - 0.5, y: size - 0.5), radius: 28, style: style, position: .bottomLeft))
    }

    @Test(arguments: [CornerStyle.continuous, .circular])
    func rightCornerIsMirrored(style: CornerStyle) {
        let size = style.extent(forRadius: 28)
        #expect(!visible(CGPoint(x: size - 0.5, y: 0.5), radius: 28, style: style, position: .bottomRight))
        #expect(visible(CGPoint(x: 0.5, y: size - 0.5), radius: 28, style: style, position: .bottomRight))
    }

    @Test func largerRadiusCoversMore() {
        let point = CGPoint(x: 4, y: 4)
        #expect(visible(point, radius: 8, style: .circular, position: .bottomLeft))
        #expect(!visible(point, radius: 28, style: .circular, position: .bottomLeft))
    }

    /// Height of the black area at a given x, found by bisection.
    private func blackHeight(atX x: CGFloat, radius: CGFloat, style: CornerStyle) -> CGFloat {
        var low: CGFloat = 0
        var high = style.extent(forRadius: radius)
        for _ in 0..<40 {
            let mid = (low + high) / 2
            if visible(CGPoint(x: x, y: mid), radius: radius, style: style, position: .bottomLeft) {
                high = mid
            } else {
                low = mid
            }
        }
        return high
    }

    /// At the far edge of the window the curve must already be flat,
    /// otherwise the window cuts the curve off with a visible step.
    @Test(arguments: [CornerStyle.continuous, .circular], [8.0, 18, 28, 40])
    func windowHoldsTheWholeCurve(style: CornerStyle, radius: CGFloat) {
        let edge = style.extent(forRadius: radius)
        #expect(blackHeight(atX: edge, radius: radius, style: style) < 0.01)
    }

    @Test func continuousCurveNeedsALargerWindow() {
        #expect(CornerStyle.circular.extent(forRadius: 28) == 28)
        #expect(CornerStyle.continuous.extent(forRadius: 28) == 43)
    }

    @Test func cornerSelectionPositions() {
        #expect(CornerSelection.both.positions == [.bottomLeft, .bottomRight])
        #expect(CornerSelection.left.positions == [.bottomLeft])
        #expect(CornerSelection.right.positions == [.bottomRight])
    }
}
