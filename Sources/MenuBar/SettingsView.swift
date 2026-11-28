import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    let status: OverlayStatus
    let onQuit: () -> Void
    let onReopen: () -> Void

    @State private var launchAtLogin = LaunchAtLogin.isEnabled
    @State private var launchMessage: String?
    @State private var launchNeedsApproval = LaunchAtLogin.needsApproval

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !settings.hasSeenWelcome {
                WelcomeCard(shortcutsEnabled: settings.shortcutsEnabled) {
                    settings.hasSeenWelcome = true
                }
            }
            CornerToggle(
                isOn: cornersBinding,
                radius: settings.radius,
                corners: settings.corners,
                subtitle: settings.pausedUntil == nil ? nil : "Dijeda"
            )
            if settings.isEnabled {
                PauseRow(settings: settings)
            }
            if settings.isEnabled && !status.hasBuiltinScreen {
                Label(
                    "Layar MacBook tidak terdeteksi, misalnya karena lid ditutup. Sudut muncul lagi begitu layarnya aktif.",
                    systemImage: "info.circle"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
            RadiusSection(settings: settings)
            Divider()
            optionsSection
            Divider()
            AppFooter(onQuit: onQuit)
        }
        .padding(16)
        .frame(width: 300)
        .onAppear(perform: refreshLaunchAtLogin)
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

            SwitchRow("Tutup panel saat kursor menjauh", isOn: $settings.autoClosesPopover)

            SwitchRow("Shortcut keyboard", isOn: $settings.shortcutsEnabled)

            if settings.shortcutsEnabled {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(AppShortcut.allCases, id: \.self) { shortcut in
                        HStack(spacing: 6) {
                            Text(shortcut.keys)
                                .monospaced()
                            Text(shortcut.title)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(shortcut.spokenKeys): \(shortcut.title)")
                        .accessibilityAddTraits(.isStaticText)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            SwitchRow("Sembunyikan ikon menu bar", isOn: $settings.hidesMenuBarIcon)

            if settings.hidesMenuBarIcon {
                Text(settings.shortcutsEnabled
                    ? "Ikon hilang setelah panel ini ditutup. Tekan \(AppShortcut.settings.keys), atau buka lagi RoundedCorners dari Spotlight, untuk kembali ke sini."
                    : "Ikon hilang setelah panel ini ditutup. Buka lagi RoundedCorners dari Spotlight atau Launchpad untuk kembali ke sini.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            SettingsFileRow(settings: settings, reopen: onReopen)
        }
    }

    /// The tile shows whether corners are on screen; tapping it while paused resumes.
    private var cornersBinding: Binding<Bool> {
        Binding(
            get: { settings.showsCorners },
            set: { _ in settings.toggleCorners() }
        )
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
