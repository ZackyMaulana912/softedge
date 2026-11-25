import SwiftUI

/// Short introduction shown at the top of the settings until it is dismissed.
struct WelcomeCard: View {
    let shortcutsEnabled: Bool
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Selamat datang di RoundedCorners")
                .font(.system(size: 13, weight: .semibold))

            VStack(alignment: .leading, spacing: 6) {
                tip("rectangle.roundedbottom", "Sudut bawah layar MacBook sekarang sudah melengkung.")
                tip("slider.horizontal.3", "Atur besar lengkungannya di bawah, layar langsung ikut berubah.")
                tip("cursorarrow.click.2", "Klik kanan ikon di menu bar untuk menyalakan atau mematikan.")
                if shortcutsEnabled {
                    tip("keyboard", "Atau tekan \(AppShortcut.toggle.keys) dari app mana saja.")
                }
            }
            .font(.caption)

            HStack {
                Spacer()
                Button("Mengerti", action: onDismiss)
                    .controlSize(.small)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.accentColor.opacity(0.1))
        )
        .accessibilityElement(children: .contain)
    }

    private func tip(_ symbol: String, _ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Image(systemName: symbol)
                .foregroundStyle(Color.accentColor)
                .frame(width: 16)
                .accessibilityHidden(true)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
