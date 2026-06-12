import SwiftUI

struct ColorPaletteButtonStyle: ButtonStyle {
    let color: Color
    let selection: Bool

    func makeBody(configuration: Configuration) -> some View {
        Rectangle()
            .frame(width: 16, height: 16)
            .foregroundColor(color)
            .cornerRadius(2)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(selection ? Color.primary : Color.clear)
            )
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

extension ButtonStyle where Self == ColorPaletteButtonStyle {
    static func colorPalette(color: Color, selection: Bool) -> ColorPaletteButtonStyle {
        ColorPaletteButtonStyle(color: color, selection: selection)
    }
}
