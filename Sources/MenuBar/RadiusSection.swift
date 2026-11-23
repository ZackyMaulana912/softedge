import AppKit
import SwiftUI

/// Radius slider with its label and current value.
struct RadiusSection: View {
    @Bindable var settings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Radius sudut")
                Spacer()
                if settings.radius != AppSettings.defaultRadius {
                    Button {
                        settings.radius = AppSettings.defaultRadius
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
                    .help("Kembalikan ke \(Int(AppSettings.defaultRadius)) pt")
                    .accessibilityLabel("Kembalikan radius ke \(Int(AppSettings.defaultRadius)) pt")
                }
                Text("\(Int(settings.radius)) pt")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Slider(
                value: Binding(
                    get: { settings.radius },
                    set: { setRadiusFromSlider($0) }
                ),
                in: AppSettings.radiusRange
            ) {
                Text("Radius sudut")
            } minimumValueLabel: {
                Text("\(Int(AppSettings.radiusRange.lowerBound))")
            } maximumValueLabel: {
                Text("\(Int(AppSettings.radiusRange.upperBound))")
            }
            .labelsHidden()
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .disabled(!settings.isEnabled)
        .opacity(settings.isEnabled ? 1 : 0.45)
    }

    /// The slider sticks a little at the default size and taps the trackpad
    /// when it lands there, so the default is easy to find again by feel.
    private func setRadiusFromSlider(_ value: Double) {
        let snapDistance = 0.8
        let target = abs(value - AppSettings.defaultRadius) < snapDistance
            ? AppSettings.defaultRadius
            : value.rounded()
        if target == AppSettings.defaultRadius && settings.radius != AppSettings.defaultRadius {
            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
        }
        settings.radius = target
    }
}
