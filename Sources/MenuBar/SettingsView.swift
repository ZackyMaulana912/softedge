import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    let onQuit: () -> Void

    @State private var launchAtLogin = LaunchAtLogin.isEnabled
    @State private var launchMessage: String?
    @State private var launchNeedsApproval = LaunchAtLogin.needsApproval

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CornerToggle(isOn: $settings.isEnabled, radius: settings.radius)
            radiusSection
            Divider()
            optionsSection
            Divider()
            HStack {
                Spacer()
                Button("Quit RoundedCorners", action: onQuit)
                    .keyboardShortcut("q")
            }
        }
        .padding(16)
        .frame(width: 300)
        .onAppear(perform: refreshLaunchAtLogin)
    }

    private var radiusSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Corner radius")
                Spacer()
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
                Text("Corner radius")
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
            Toggle("Launch at login", isOn: launchBinding)

            if let launchMessage {
                Text(launchMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if launchNeedsApproval {
                Button("Open Login Items Settings") {
                    LaunchAtLogin.openSystemSettings()
                }
                .controlSize(.small)
            }

            Toggle("Hide menu bar icon", isOn: $settings.hidesMenuBarIcon)

            if settings.hidesMenuBarIcon {
                Text("The icon disappears when this panel closes. Open RoundedCorners again from Spotlight or Launchpad to get back here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .toggleStyle(.switch)
        .controlSize(.small)
    }

    private var launchBinding: Binding<Bool> {
        Binding(
            get: { launchAtLogin },
            set: { newValue in
                do {
                    try LaunchAtLogin.setEnabled(newValue)
                    launchMessage = nil
                } catch {
                    launchMessage = "Could not change launch at login: \(error.localizedDescription)"
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
            launchMessage = "macOS needs your approval in System Settings, Login Items."
        }
    }
}
