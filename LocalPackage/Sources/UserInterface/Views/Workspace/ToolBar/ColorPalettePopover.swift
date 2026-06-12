import SwiftUI

struct ColorPalettePopover: View {
    let selectedPaletteIndex: Int
    let opacity: CGFloat
    let selectColorHandler: (Int) -> Void
    let opacityUpdateBeganHandler: () -> Void
    let opacityChangedHandler: (CGFloat) -> Void

    var body: some View {
        VStack {
            HStack(spacing: 4) {
                ForEach(Color.palette.indices, id: \.self) { column in
                    VStack(spacing: 4) {
                        ForEach(Color.palette[column].indices, id: \.self) { row in
                            let index = column + 8 * row
                            Button {
                                selectColorHandler(index)
                            } label: {
                                EmptyView()
                            }
                            .buttonStyle(.colorPalette(
                                color: Color.palette[column][row],
                                selection: selectedPaletteIndex == index
                            ))
                        }
                    }
                }
            }
            HStack(spacing: 8) {
                Text(String(format: "%3.1f", opacity))
                    .font(.system(.body, design: .monospaced))
                Slider(
                    value: Binding<CGFloat>(
                        get: { opacity },
                        set: { opacityChangedHandler($0) }
                    ),
                    in: (0.2 ... 1)
                ) { began in
                    if began {
                        opacityUpdateBeganHandler()
                    }
                }
                .frame(height: 20)
                Image(systemName: "checkerboard.rectangle")
                    .frame(height: 20)
                    .opacity(opacity)
            }
            .help(Text("opacity", bundle: .module))
        }
        .padding(8)
    }
}
