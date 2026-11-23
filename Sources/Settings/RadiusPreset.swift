/// A named radius the settings offer as a one-click choice.
struct RadiusPreset: Identifiable, Sendable {
    let name: String
    let radius: Double

    var id: Double { radius }
}
