import AppKit
import UniformTypeIdentifiers

/// The save and open dialogs for the settings file.
@MainActor
enum SettingsFile {
    /// Returns a short note for the popover, or nil when the dialog was cancelled.
    static func export(_ settings: AppSettings) -> String? {
        let panel = NSSavePanel()
        panel.title = "Ekspor pengaturan"
        panel.message = "Simpan pengaturan RoundedCorners untuk dipakai lagi atau dibawa ke Mac lain."
        panel.nameFieldStringValue = "Pengaturan RoundedCorners.json"
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return nil }

        do {
            try SettingsSnapshot(settings).data().write(to: url, options: .atomic)
            return "Tersimpan di \(url.lastPathComponent)."
        } catch {
            NSLog("RoundedCorners: export failed: %@", String(describing: error))
            return "Gagal menyimpan: \(error.localizedDescription)"
        }
    }
}
