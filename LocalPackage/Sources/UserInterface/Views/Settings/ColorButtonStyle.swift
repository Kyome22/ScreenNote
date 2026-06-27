import SwiftUI

struct ColorButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .frame(width: 32, height: 16)
            .foregroundStyle(color)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(Color.secondary)
            )
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

extension ButtonStyle where Self == ColorButtonStyle {
    static func color(_ color: Color) -> ColorButtonStyle {
        ColorButtonStyle(color: color)
    }
}
