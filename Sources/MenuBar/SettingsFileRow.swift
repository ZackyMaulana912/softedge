import SwiftUI

/// Buttons to save the settings to a file, with a note about the last result.
struct SettingsFileRow: View {
    let settings: AppSettings
    /// The popover closes while a file dialog is open, this brings it back.
    let reopen: () -> Void

    @State private var note: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("File pengaturan")
                Spacer()
                Button("Ekspor...") {
                    note = SettingsFile.export(settings) ?? note
                    reopen()
                }
                .controlSize(.small)
                .help("Simpan pengaturan ke file")
            }
            if let note {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
