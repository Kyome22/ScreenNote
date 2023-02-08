/*
  LineWidthPopover.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/04.
  
*/

import SwiftUI

struct LineWidthPopover: View {
    @Binding private var lineWidth: CGFloat
    @Binding private var color: Color
    @Binding private var alpha: CGFloat
    private let willUpdateLineWidthHandler: () -> Void

    init(
        lineWidth: Binding<CGFloat>,
        color: Binding<Color>,
        alpha: Binding<CGFloat>,
        willUpdateLineWidthHandler: @escaping () -> Void
    ) {
        _lineWidth = lineWidth
        _color = color
        _alpha = alpha
        self.willUpdateLineWidthHandler = willUpdateLineWidthHandler
    }

    var body: some View {
        VStack() {
            Rectangle()
                .foregroundColor(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 0.5 * lineWidth)
                        .foregroundColor(color)
                        .opacity(alpha)
                        .frame(height: lineWidth)
                )
                .frame(height: 20)
            HStack(spacing: 8) {
                Text(String(format: "%4.1f", lineWidth))
                    .font(.system(size: 13, design: .monospaced))
                Slider(value: $lineWidth, in: (1 ... 20)) { flag in
                    if flag {
                        willUpdateLineWidthHandler()
                    }
                }
                .frame(width: 150, height: 20)
            }
        }
        .padding(8)
    }
}

struct LineWidthPopover_Previews: PreviewProvider {
    static var previews: some View {
        LineWidthPopover(lineWidth: .constant(4.0),
                         color: .constant(.white),
                         alpha: .constant(0.8),
                         willUpdateLineWidthHandler: {})
    }
}
