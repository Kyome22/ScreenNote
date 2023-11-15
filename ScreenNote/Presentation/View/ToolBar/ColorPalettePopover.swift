/*
 ColorPalettePopover.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/03.
  
*/

import SwiftUI

struct ColorPalettePopover: View {
    @Binding private var color: Color
    @Binding private var opacity: CGFloat
    private let colors: [[Color]]
    private let startUpdatingOpacityHandler: () -> Void

    init(
        color: Binding<Color>,
        opacity: Binding<CGFloat>,
        colors: [[Color]],
        startUpdatingOpacityHandler: @escaping () -> Void
    ) {
        _color = color
        _opacity = opacity
        self.colors = colors
        self.startUpdatingOpacityHandler = startUpdatingOpacityHandler
    }

    var body: some View {
        VStack {
            HStack(spacing: 4) {
                ForEach(0 ..< colors.count, id: \.self) { i in
                    VStack(spacing: 4) {
                        ForEach(colors[i], id: \.hashValue) { color in
                            Button {
                                self.color = color
                            } label: {
                                EmptyView()
                            }
                            .buttonStyle(.colorPalette(color, Binding(
                                get: { self.color == color },
                                set: { _, _ in }
                            )))
                        }
                    }
                }
            }
            HStack(spacing: 8) {
                Text(String(format: "%3.1f", opacity))
                    .font(.system(.body, design: .monospaced))
                Slider(value: $opacity, in: (0.2 ... 1)) { flag in
                    if flag {
                        startUpdatingOpacityHandler()
                    }
                }
                .frame(height: 20)
                Image(systemName: "checkerboard.rectangle")
                    .frame(height: 20)
                    .opacity(opacity)
            }
            .help("opacity")
        }
        .padding(8)
    }
}

#Preview {
    ColorPalettePopover(color: .constant(.white),
                        opacity: .constant(0.8),
                        colors: [[]],
                        startUpdatingOpacityHandler: {})
}
