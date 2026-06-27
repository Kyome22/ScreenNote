import SwiftUI

struct LineWidthPopover: View {
    let lineWidth: CGFloat
    let color: Color
    let opacity: CGFloat
    let lineWidthUpdateBeganHandler: () async -> Void
    let lineWidthChangedHandler: (CGFloat) async -> Void

    var body: some View {
        VStack {
            Rectangle()
                .foregroundStyle(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 0.5 * lineWidth)
                        .foregroundStyle(color)
                        .opacity(opacity)
                        .frame(height: lineWidth)
                )
                .frame(height: 20)
            HStack(spacing: 8) {
                Text(String(format: "%4.1f", lineWidth))
                    .font(.system(size: 13, design: .monospaced))
                Slider(
                    value: Binding<CGFloat>(
                        get: { lineWidth },
                        asyncSet: { await lineWidthChangedHandler($0) }
                    ),
                    in: (1 ... 20)
                ) { began in
                    if began {
                        Task {
                            await lineWidthUpdateBeganHandler()
                        }
                    }
                }
                .frame(width: 150, height: 20)
            }
        }
        .padding(8)
    }
}
