import AppKit
import SwiftUI

/// Bottom row of the settings: app version, the update check, and Quit.
struct AppFooter: View {
    let onQuit: () -> Void

    @State private var updates = UpdateChecker()

    private static let releasesURL = URL(string: "https://github.com/ZackyMaulana912/softedge/releases/latest")!

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Versi \(version)")
                    .foregroundStyle(.secondary)
                updateStatus
            }
            .font(.caption)

            Spacer()

            Button("Keluar", action: onQuit)
                .keyboardShortcut("q")
                .help("Tutup RoundedCorners")
        }
    }

    @ViewBuilder
    private var updateStatus: some View {
        switch updates.state {
        case .idle:
            checkButton("Cek pembaruan")
        case .checking:
            HStack(spacing: 4) {
                ProgressView()
                    .controlSize(.mini)
                Text("Memeriksa...")
            }
            .foregroundStyle(.secondary)
        case .upToDate:
            Label("Sudah versi terbaru", systemImage: "checkmark")
                .foregroundStyle(.secondary)
        case .available(let version, let page):
            Button("Unduh versi \(version)") {
                NSWorkspace.shared.open(page)
            }
            .buttonStyle(.link)
            .help("Buka halaman rilis versi \(version) di GitHub")
        case .failed(let message):
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(message)
                        .foregroundStyle(.secondary)
                    checkButton("Coba lagi")
                }
                Button("Buka halaman rilis") {
                    NSWorkspace.shared.open(Self.releasesURL)
                }
                .buttonStyle(.link)
            }
        }
    }

    private func checkButton(_ title: String) -> some View {
        Button(title) {
            Task { await updates.check() }
        }
        .buttonStyle(.link)
        .help("Tanya GitHub apakah ada versi yang lebih baru")
    }
}
