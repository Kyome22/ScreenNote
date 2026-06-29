import DataSource
import Model
import SwiftUI

struct LineWidthButton: View {
    @Bindable var store: Workspace

    private var lineWidth: CGFloat {
        store.canvasState.objectProperties.lineWidth
    }

    var body: some View {
        Button {
            Task {
                await store.send(.lineWidthButtonTapped)
            }
        } label: {
            Image(systemName: "lineweight")
        }
        .buttonStyle(.toolBar(store.toolBarPosition.direction))
        .help(Text("lineWidth", bundle: .module))
        .popover(isPresented: $store.showingLineWidthPopover, arrowEdge: store.toolBarPosition.arrowEdge) {
            VStack {
                Rectangle()
                    .foregroundStyle(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 0.5 * lineWidth)
                            .foregroundStyle(Color.palette(at: store.canvasState.objectProperties.paletteIndex))
                            .opacity(store.canvasState.objectProperties.opacity)
                            .frame(height: lineWidth)
                    )
                    .frame(height: 20)
                HStack(spacing: 8) {
                    Text(String(format: "%4.1f", lineWidth))
                        .font(.system(size: 13, design: .monospaced))
                    Slider(
                        value: Binding<CGFloat>(
                            get: { lineWidth },
                            asyncSet: { await store.send(.lineWidthChanged($0)) }
                        ),
                        in: (1 ... 20)
                    ) { began in
                        if began {
                            Task {
                                await store.send(.lineWidthUpdateBegan)
                            }
                        }
                    }
                    .frame(width: 150, height: 20)
                }
            }
            .padding(16)
        }
    }
}
