import CoreGraphics
import SwiftUI

enum CornerPosition: CaseIterable {
    case bottomLeft
    case bottomRight
}

enum CornerPath {
    /// Path of the visible (transparent) area inside a corner window of the given size.
    /// Coordinates are AppKit style: origin at the bottom left.
    static func visibleArea(size: CGFloat, radius: CGFloat, style: CornerStyle, position: CornerPosition) -> CGPath {
        // A rounded rect much larger than the window, aligned so only one of its
        // corners falls inside the window. The shape is symmetric, so the
        // y-down convention of SwiftUI paths does not matter here.
        let span = size * 4
        let originX: CGFloat = position == .bottomLeft ? 0 : size - span
        let rect = CGRect(x: originX, y: 0, width: span, height: span)

        switch style {
        case .continuous:
            return RoundedRectangle(cornerRadius: radius, style: .continuous).path(in: rect).cgPath
        case .circular:
            return RoundedRectangle(cornerRadius: radius, style: .circular).path(in: rect).cgPath
        }
    }
}
