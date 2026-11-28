import Carbon.HIToolbox

/// System wide shortcuts. All use Control + Option + Command, a combination
/// few other apps claim.
enum AppShortcut: UInt32, CaseIterable {
    case toggle = 1
    case settings = 2
    case radiusUp = 3
    case radiusDown = 4

    static let modifiers = UInt32(controlKey | optionKey | cmdKey)

    var keyCode: UInt32 {
        switch self {
        case .toggle: return UInt32(kVK_ANSI_R)
        case .settings: return UInt32(kVK_ANSI_P)
        case .radiusUp: return UInt32(kVK_ANSI_Equal)
        case .radiusDown: return UInt32(kVK_ANSI_Minus)
        }
    }

    var keys: String {
        switch self {
        case .toggle: return "⌃⌥⌘R"
        case .settings: return "⌃⌥⌘P"
        case .radiusUp: return "⌃⌥⌘+"
        case .radiusDown: return "⌃⌥⌘−"
        }
    }

    /// The keys in words, since screen readers often skip the symbols.
    var spokenKeys: String {
        switch self {
        case .toggle: return "Control Option Command R"
        case .settings: return "Control Option Command P"
        case .radiusUp: return "Control Option Command plus"
        case .radiusDown: return "Control Option Command minus"
        }
    }

    var title: String {
        switch self {
        case .toggle: return "nyalakan atau matikan sudut"
        case .settings: return "buka atau tutup pengaturan"
        case .radiusUp: return "perbesar radius"
        case .radiusDown: return "perkecil radius"
        }
    }
}
