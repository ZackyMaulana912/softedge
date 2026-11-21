import SwiftUI

/// A label on the left and a small switch pinned to the right edge,
/// so switches line up no matter how long each label is.
struct SwitchRow: View {
    let title: String
    @Binding var isOn: Bool

    init(_ title: String, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .toggleStyle(.switch)
        .controlSize(.small)
    }
}
