import SwiftUI

struct SelectableColorButtonStyle: ButtonStyle {
    var color: Color
    var selection: Bool

    func makeBody(configuration: Configuration) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .frame(width: 32, height: 16)
            .foregroundStyle(color)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(Color.accentColor.opacity(selection ? 0.6 : 0.0))
            )
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

extension ButtonStyle where Self == SelectableColorButtonStyle {
    static func selectableColor(color: Color, selection: Bool) -> SelectableColorButtonStyle {
        SelectableColorButtonStyle(color: color, selection: selection)
    }
}
