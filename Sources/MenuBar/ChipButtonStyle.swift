import SwiftUI

/// Small capsule button, filled with the accent color when selected.
struct ChipButtonStyle: ButtonStyle {
    var isSelected = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .background(Capsule().fill(
                isSelected ? Color.accentColor : Color.primary.opacity(configuration.isPressed ? 0.16 : 0.08)
            ))
            .contentShape(Capsule())
    }
}
