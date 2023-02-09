/*
  ColorButtonStyle.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/09.
  
*/

import SwiftUI

struct ColorButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        Rectangle()
            .frame(width: 32, height: 16)
            .foregroundColor(color)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.secondary)
            )
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

extension ButtonStyle where Self == ColorButtonStyle {
    static func color(_ color: Color) -> ColorButtonStyle {
        return ColorButtonStyle(color: color)
    }
}
