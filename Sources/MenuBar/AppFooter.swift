import AppKit
import SwiftUI

/// Bottom row of the settings: app version, the update check, and Quit.
struct AppFooter: View {
    let onQuit: () -> Void

    @State private var updates = UpdateChecker()

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
        case .available(let version, _):
            Text("Versi \(version) tersedia")
        case .failed(let message):
            HStack(spacing: 4) {
                Text(message)
                    .foregroundStyle(.secondary)
                checkButton("Coba lagi")
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
