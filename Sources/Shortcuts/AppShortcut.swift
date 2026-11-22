import Carbon.HIToolbox

/// System wide shortcuts. All use Control + Option + Command, a combination
/// few other apps claim.
enum AppShortcut: UInt32, CaseIterable {
    case toggle = 1
    case settings = 2

    static let modifiers = UInt32(controlKey | optionKey | cmdKey)

    var keyCode: UInt32 {
        switch self {
        case .toggle: return UInt32(kVK_ANSI_R)
        case .settings: return UInt32(kVK_ANSI_P)
        }
    }

    var keys: String {
        switch self {
        case .toggle: return "⌃⌥⌘R"
        case .settings: return "⌃⌥⌘P"
        }
    }

    var title: String {
        switch self {
        case .toggle: return "nyalakan atau matikan sudut"
        case .settings: return "buka atau tutup pengaturan"
        }
    }
}
