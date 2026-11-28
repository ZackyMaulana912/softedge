import AppKit
import SwiftUI

/// Which corners to cover, plus the radius slider with its value and one-click sizes.
struct RadiusSection: View {
    @Bindable var settings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Sudut")
                    .lineLimit(1)
                Spacer()
                Picker("Sudut", selection: $settings.corners) {
                    ForEach(CornerSelection.allCases) { selection in
                        Text(selection.title).tag(selection)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .controlSize(.small)
                .frame(width: 190)
            }
            .padding(.bottom, 6)

            HStack {
                Text("Radius sudut")
                Spacer()
                Text("\(Int(settings.radius)) pt")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    // The slider below already reads out the value.
                    .accessibilityHidden(true)
            }
            Slider(value: radiusBinding, in: AppSettings.radiusRange) {
                Text("Radius sudut")
            } minimumValueLabel: {
                Text("\(Int(AppSettings.radiusRange.lowerBound))")
            } maximumValueLabel: {
                Text("\(Int(AppSettings.radiusRange.upperBound))")
            }
            .labelsHidden()
            // Without this, VoiceOver reads the 8 and 40 at the ends as buttons.
            .accessibilityRepresentation {
                Slider(value: radiusBinding, in: AppSettings.radiusRange, step: 1) {
                    Text("Radius sudut")
                }
                .accessibilityValue("\(Int(settings.radius)) poin")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                ForEach(AppSettings.presets) { preset in
                    let isCurrent = settings.radius == preset.radius
                    Button(preset.name) {
                        settings.radius = preset.radius
                    }
                    .buttonStyle(ChipButtonStyle(isSelected: isCurrent))
                    .help("\(Int(preset.radius)) pt")
                    .accessibilityAddTraits(isCurrent ? .isSelected : [])
                }
            }
        }
        .disabled(!settings.isEnabled)
        .opacity(settings.isEnabled ? 1 : 0.45)
    }

    private var radiusBinding: Binding<Double> {
        Binding(
            get: { settings.radius },
            set: { setRadiusFromSlider($0) }
        )
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
