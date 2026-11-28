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

    /// A settings file is a few hundred bytes, anything much larger is not one.
    private static let largestFile = 64 * 1024

    static func importFile(into settings: AppSettings) -> String? {
        let panel = NSOpenPanel()
        panel.title = "Impor pengaturan"
        panel.message = "Pilih file pengaturan RoundedCorners yang pernah diekspor."
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        guard panel.runModal() == .OK, let url = panel.url else { return nil }

        do {
            let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            guard size <= largestFile else { throw SettingsSnapshot.ReadError.notSettings }
            let snapshot = try SettingsSnapshot.read(Data(contentsOf: url))
            snapshot.apply(to: settings)
            return "Pengaturan dimuat dari \(url.lastPathComponent)."
        } catch let error as SettingsSnapshot.ReadError {
            return error.localizedDescription
        } catch {
            NSLog("RoundedCorners: import failed: %@", String(describing: error))
            return "Gagal membuka file: \(error.localizedDescription)"
        }
    }
}
