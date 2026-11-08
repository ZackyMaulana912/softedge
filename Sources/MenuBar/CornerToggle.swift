import SwiftUI

/// Main on/off control: a tile with a small laptop screen whose bottom corners
/// round off when the effect is on.
struct CornerToggle: View {
    @Binding var isOn: Bool
    let radius: Double

    private let tileShape = RoundedRectangle(cornerRadius: 14, style: .continuous)

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                isOn.toggle()
            }
        } label: {
            HStack(spacing: 14) {
                ScreenGlyph(isOn: isOn, radius: radius)
                    .frame(width: 60, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Rounded Corners")
                        .font(.system(size: 13, weight: .semibold))
                    Text(isOn ? "On" : "Off")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                PowerBadge(isOn: isOn)
            }
            .padding(12)
            .background(tileShape.fill(isOn ? Color.accentColor.opacity(0.14) : Color.primary.opacity(0.05)))
            .overlay(tileShape.strokeBorder(isOn ? Color.accentColor.opacity(0.45) : Color.primary.opacity(0.1)))
            .contentShape(tileShape)
        }
        .buttonStyle(.plain)
        .accessibilityRepresentation {
            Toggle("Rounded Corners", isOn: $isOn)
        }
    }
}

private struct ScreenGlyph: View {
    let isOn: Bool
    let radius: Double

    /// Maps the real radius range onto what fits in the small glyph.
    private var glyphRadius: CGFloat {
        guard isOn else { return 1.5 }
        let range = AppSettings.radiusRange
        let t = (radius - range.lowerBound) / (range.upperBound - range.lowerBound)
        return 3 + t * 9
    }

    var body: some View {
        let screen = UnevenRoundedRectangle(
            topLeadingRadius: 3,
            bottomLeadingRadius: glyphRadius,
            bottomTrailingRadius: glyphRadius,
            topTrailingRadius: 3,
            style: .continuous
        )

        VStack(spacing: 2) {
            screen
                .fill(LinearGradient(
                    colors: [Color(white: 0.3), Color(white: 0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .overlay(screen.strokeBorder(isOn ? Color.accentColor : Color.secondary.opacity(0.5), lineWidth: 1.5))
                .shadow(color: isOn ? Color.accentColor.opacity(0.6) : .clear, radius: 4)
                .padding(.horizontal, 6)

            Capsule()
                .fill(Color.secondary.opacity(0.6))
                .frame(height: 3)
        }
    }
}

private struct PowerBadge: View {
    let isOn: Bool

    var body: some View {
        Image(systemName: "power")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(isOn ? Color.white : Color.secondary)
            .frame(width: 28, height: 28)
            .background(Circle().fill(isOn ? Color.accentColor : Color.primary.opacity(0.08)))
            .overlay(Circle().strokeBorder(isOn ? Color.clear : Color.primary.opacity(0.15)))
    }
}
