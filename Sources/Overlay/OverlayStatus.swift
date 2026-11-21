import Observation

/// What the overlay is actually doing, so the settings can explain
/// why no corners are visible.
@MainActor
@Observable
final class OverlayStatus {
    var hasBuiltinScreen = true
}
