/// Which bottom corners get the black overlay.
enum CornerSelection: String, CaseIterable, Identifiable, Sendable {
    case both
    case left
    case right

    var id: String { rawValue }

    var title: String {
        switch self {
        case .both: return "Keduanya"
        case .left: return "Kiri"
        case .right: return "Kanan"
        }
    }

    var positions: Set<CornerPosition> {
        switch self {
        case .both: return [.bottomLeft, .bottomRight]
        case .left: return [.bottomLeft]
        case .right: return [.bottomRight]
        }
    }
}
