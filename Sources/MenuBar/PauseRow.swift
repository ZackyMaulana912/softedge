import SwiftUI

/// Pause buttons while the corners are on, or the pause end with a way out.
struct PauseRow: View {
    let settings: AppSettings

    var body: some View {
        HStack(spacing: 6) {
            if let until = settings.pausedUntil {
                Image(systemName: "pause.circle")
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                Text("Dijeda sampai \(PauseSchedule.label(for: until))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
                Button("Lanjutkan") {
                    settings.resume()
                }
                .buttonStyle(ChipButtonStyle(isSelected: true))
                .accessibilityLabel("Lanjutkan sekarang")
            } else {
                Text("Jeda")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    // Each button below says "Jeda" itself.
                    .accessibilityHidden(true)
                Spacer(minLength: 0)
                Button("1 jam") {
                    settings.pause(until: PauseSchedule.oneHour())
                }
                .buttonStyle(ChipButtonStyle())
                .accessibilityLabel("Jeda 1 jam")
                Button("Sampai besok pagi") {
                    settings.pause(until: PauseSchedule.nextMorning())
                }
                .buttonStyle(ChipButtonStyle())
                .accessibilityLabel("Jeda sampai \(PauseSchedule.label(for: PauseSchedule.nextMorning()))")
            }
        }
    }
}
