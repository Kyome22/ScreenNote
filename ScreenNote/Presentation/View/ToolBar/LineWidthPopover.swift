/*
  LineWidthPopover.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/04.
  
*/

import SwiftUI

struct LineWidthPopover: View {
    @Binding private var lineWidth: CGFloat
    private let color: Color
    private let opacity: CGFloat
    private let startUpdatingLineWidthHandler: () -> Void

    init(
        lineWidth: Binding<CGFloat>,
        color: Color,
        opacity: CGFloat,
        startUpdatingLineWidthHandler: @escaping () -> Void
    ) {
        _lineWidth = lineWidth
        self.color = color
        self.opacity = opacity
        self.startUpdatingLineWidthHandler = startUpdatingLineWidthHandler
    }

    var body: some View {
        VStack() {
            Rectangle()
                .foregroundColor(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 0.5 * lineWidth)
                        .foregroundColor(color)
                        .opacity(opacity)
                        .frame(height: lineWidth)
                )
                .frame(height: 20)
            HStack(spacing: 8) {
                Text(String(format: "%4.1f", lineWidth))
                    .font(.system(size: 13, design: .monospaced))
                Slider(value: $lineWidth, in: (1 ... 20)) { flag in
                    if flag {
                        startUpdatingLineWidthHandler()
                    }
                }
                .frame(width: 150, height: 20)
            }
        }
        .padding(8)
    }
}

#Preview {
    LineWidthPopover(lineWidth: .constant(4.0),
                     color: .white,
                     opacity: 0.8,
                     startUpdatingLineWidthHandler: {})
}
