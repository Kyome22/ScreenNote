import SwiftUI

struct SelectableColorButtonStyle: ButtonStyle {
    let color: Color
    let selection: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 32, height: 16)
            .foregroundStyle(Color.clear)
            .background(color)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.accentColor.opacity(selection ? 0.6 : 0.0), lineWidth: 2)
            )
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

extension ButtonStyle where Self == SelectableColorButtonStyle {
    static func selectableColor(color: Color, selection: Bool) -> SelectableColorButtonStyle {
        SelectableColorButtonStyle(color: color, selection: selection)
    }
}
