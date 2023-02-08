/*
  ToolBarRadioButtonStyle.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/03.
  
*/

import SwiftUI

struct ToolBarRadioButtonStyle: ButtonStyle {
    let width: CGFloat
    @Binding var selection: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, design: .monospaced))
            .frame(width: width, height: 30, alignment: .center)
            .background(
                (selection ? Color.accentColor : Color.gray)
                    .opacity(configuration.isPressed ? 0.8 : 0.6)
            )
            .cornerRadius(6)
    }
}

extension ButtonStyle where Self == ToolBarRadioButtonStyle {
    static func toolBarRadio(
        _ toolBarDirection: ToolBarDirection,
        _ selection: Binding<Bool>
    ) -> ToolBarRadioButtonStyle {
        let width: CGFloat = toolBarDirection == .vertical ? 30 : 40
        return ToolBarRadioButtonStyle(width: width, selection: selection)
    }
}
