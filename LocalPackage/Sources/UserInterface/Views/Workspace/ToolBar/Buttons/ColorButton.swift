import DataSource
import Model
import SwiftUI

struct ColorButton: View {
    @Bindable var store: Workspace

    private var currentIndex: Int {
        store.canvasState.objectProperties.paletteIndex
    }

    private var opacity: CGFloat {
        store.canvasState.objectProperties.opacity
    }

    var body: some View {
        Button {
            Task {
                await store.send(.colorButtonTapped)
            }
        } label: {
            Image(systemName: "drop.fill")
                .foregroundStyle(Color.palette(at: currentIndex))
                .opacity(opacity)
        }
        .buttonStyle(.toolBar(store.toolBarPosition.direction))
        .help(Text("colorPalette", bundle: .module))
        .popover(isPresented: $store.showingColorPopover, arrowEdge: store.toolBarPosition.arrowEdge) {
            VStack {
                HStack(spacing: 4) {
                    ForEach(Color.palette.indices, id: \.self) { column in
                        VStack(spacing: 4) {
                            ForEach(Color.palette[column].indices, id: \.self) { row in
                                rowButton(
                                    currentIndex: currentIndex,
                                    index: column + 8 * row,
                                    color: Color.palette[column][row]
                                )
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
                            asyncSet: { await store.send(.opacityChanged($0)) }
                        ),
                        in: (0.2 ... 1)
                    ) { began in
                        if began {
                            Task {
                                await store.send(.opacityUpdateBegan)
                            }
                        }
                    }
                    .frame(height: 20)
                    Image(systemName: "checkerboard.rectangle")
                        .frame(height: 20)
                        .opacity(opacity)
                }
                .help(Text("opacity", bundle: .module))
            }
            .padding(16)
        }
    }

    private func rowButton(currentIndex: Int, index: Int, color: Color) -> some View {
        Button {
            Task {
                await store.send(.colorSelected(index))
            }
        } label: {
            EmptyView()
        }
        .buttonStyle(.colorPalette(color: color, selection: currentIndex == index))
    }
}
