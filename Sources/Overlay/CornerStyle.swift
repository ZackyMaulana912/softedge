import CoreGraphics

enum CornerStyle {
    /// Apple continuous curve (squircle), same as SwiftUI `.continuous`.
    case continuous
    /// Plain quarter circle, for comparison.
    case circular

    /// Switch to `.circular` to compare the two shapes on screen.
    static let current: CornerStyle = .continuous

    /// Stage 1 prototype radius in points.
    static let radius: CGFloat = 28

    /// How far the curve reaches from the corner along each edge.
    /// A continuous corner starts bending earlier than a circular one,
    /// so its window must be larger than the radius to avoid clipping the curve.
    func extent(forRadius radius: CGFloat) -> CGFloat {
        switch self {
        case .continuous: return (radius * 1.528665).rounded(.up)
        case .circular: return radius
        }
    }
}
