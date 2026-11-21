import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    let status: OverlayStatus
    let onQuit: () -> Void

    @State private var launchAtLogin = LaunchAtLogin.isEnabled
    @State private var launchMessage: String?
    @State private var launchNeedsApproval = LaunchAtLogin.needsApproval

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CornerToggle(isOn: $settings.isEnabled, radius: settings.radius)
            if settings.isEnabled && !status.hasBuiltinScreen {
                Label(
                    "Layar MacBook tidak terdeteksi, misalnya karena lid ditutup. Sudut muncul lagi begitu layarnya aktif.",
                    systemImage: "info.circle"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
            radiusSection
            Divider()
            optionsSection
            Divider()
            AppFooter(onQuit: onQuit)
        }
        .padding(16)
        .frame(width: 300)
        .onAppear(perform: refreshLaunchAtLogin)
    }

    private var radiusSection: some View {
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
                    set: { settings.radius = $0.rounded() }
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

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SwitchRow("Buka otomatis saat login", isOn: launchBinding)

            if let launchMessage {
                Text(launchMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if launchNeedsApproval {
                Button("Buka Pengaturan Login Items") {
                    LaunchAtLogin.openSystemSettings()
                }
                .controlSize(.small)
            }

            SwitchRow("Sembunyikan ikon menu bar", isOn: $settings.hidesMenuBarIcon)

            if settings.hidesMenuBarIcon {
                Text("Ikon hilang setelah panel ini ditutup. Buka lagi RoundedCorners dari Spotlight atau Launchpad untuk kembali ke sini.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var launchBinding: Binding<Bool> {
        Binding(
            get: { launchAtLogin },
            set: { newValue in
                do {
                    try LaunchAtLogin.setEnabled(newValue)
                    launchMessage = nil
                } catch {
                    launchMessage = "Gagal mengubah buka otomatis saat login: \(error.localizedDescription)"
                    NSLog("RoundedCorners: launch at login failed: %@", String(describing: error))
                }
                refreshLaunchAtLogin()
            }
        )
    }

    private func refreshLaunchAtLogin() {
        launchAtLogin = LaunchAtLogin.isEnabled
        launchNeedsApproval = LaunchAtLogin.needsApproval
        if launchNeedsApproval && launchMessage == nil {
            launchMessage = "macOS meminta persetujuanmu di System Settings > General > Login Items."
        }
    }
}
