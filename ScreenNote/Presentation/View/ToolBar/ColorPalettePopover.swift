/*
 ColorPalettePopover.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/03.
  
*/

import SwiftUI

struct ColorPalettePopover: View {
    @Binding private var color: Color
    @Binding private var alpha: CGFloat
    private let colors: [[Color]]
    private let willUpdateAlphaHandler: () -> Void

    init(
        color: Binding<Color>,
        alpha: Binding<CGFloat>,
        colors: [[Color]],
        willUpdateAlphaHandler: @escaping () -> Void
    ) {
        _color = color
        _alpha = alpha
        self.colors = colors
        self.willUpdateAlphaHandler = willUpdateAlphaHandler
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
                Image(systemName: "checkerboard.rectangle")
                    .frame(height: 20)
                    .opacity(alpha)
                Slider(value: $alpha, in: (0.2 ... 1)) { flag in
                    if flag {
                        willUpdateAlphaHandler()
                    }
                }
                .frame(height: 20)
            }
            .help("alpha")
        }
        .padding(8)
    }
}

struct ColorPalettePopover_Previews: PreviewProvider {
    static var previews: some View {
        ColorPalettePopover(color: .constant(.white),
                            alpha: .constant(0.8),
                            colors: [[]],
                            willUpdateAlphaHandler: {})
    }
}
