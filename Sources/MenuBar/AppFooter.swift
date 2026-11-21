import AppKit
import SwiftUI

/// Bottom row of the settings: app version, a link to new releases, and Quit.
struct AppFooter: View {
    let onQuit: () -> Void

    private static let releasesURL = URL(string: "https://github.com/ZackyMaulana912/softedge/releases/latest")!

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Versi \(version)")
                    .foregroundStyle(.secondary)
                Button("Cek pembaruan") {
                    NSWorkspace.shared.open(Self.releasesURL)
                }
                .buttonStyle(.link)
                .help("Buka halaman rilis terbaru di GitHub")
            }
            .font(.caption)

            Spacer()

            Button("Keluar", action: onQuit)
                .keyboardShortcut("q")
                .help("Tutup RoundedCorners")
        }
    }
}
