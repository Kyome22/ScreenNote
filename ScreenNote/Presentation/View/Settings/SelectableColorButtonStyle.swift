/*
  SelectableColorButtonStyle.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/11.
  
*/

import SwiftUI

struct SelectableColorButtonStyle: ButtonStyle {
    let color: Color
    @Binding var selection: Bool

    func makeBody(configuration: Configuration) -> some View {
        Rectangle()
            .frame(width: 32, height: 16)
            .foregroundColor(color)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.accentColor.opacity(selection ? 0.6 : 0.0), lineWidth: 2)
            )
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

extension ButtonStyle where Self == SelectableColorButtonStyle {
    static func selectableColor(
        _ color: Color,
        _ selection: Binding<Bool>
    ) -> SelectableColorButtonStyle {
        return SelectableColorButtonStyle(color: color, selection: selection)
    }
}
