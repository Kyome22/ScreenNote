import DataSource
import Model
import SwiftUI

@MainActor struct ToolBarButtons {
    @Bindable var store: Workspace
    let toolBarDirection: ToolBarDirection

    private var arrowEdge: Edge {
        store.toolBarPosition.arrowEdge
    }

    var historyButtons: some View {
        HStack(spacing: 8) {
            Button {
                Task {
                    await store.send(.undoButtonTapped)
                }
            } label: {
                Image(systemName: "arrowshape.turn.up.backward.fill")
            }
            .buttonStyle(.toolBar(toolBarDirection))
            .help(Text("goBack", bundle: .module))
            .keyboardShortcut("z", modifiers: .command)
            .disabled(store.disabledWhileInputtingText)

            Button {
                Task {
                    await store.send(.redoButtonTapped)
                }
            } label: {
                Image(systemName: "arrowshape.turn.up.forward.fill")
            }
            .buttonStyle(.toolBar(toolBarDirection))
            .help(Text("goForward", bundle: .module))
            .keyboardShortcut("z", modifiers: [.shift, .command])
            .disabled(store.disabledWhileInputtingText)
        }
    }

    func objectTypeButton(_ objectType: ObjectType) -> some View {
        Button {
            Task {
                await store.send(.objectTypeSelected(objectType))
            }
        } label: {
            Image(systemName: objectType.symbolName)
        }
        .buttonStyle(.toolBarRadio(
            toolBarDirection,
            store.canvasState.objectType == objectType
        ))
        .help(objectType.help)
    }

    var colorButton: some View {
        Button {
            Task {
                await store.send(.colorButtonTapped)
            }
        } label: {
            Image(systemName: "drop.fill")
                .foregroundStyle(Color.palette(at: store.canvasState.objectProperties.paletteIndex))
                .opacity(store.canvasState.objectProperties.opacity)
        }
        .buttonStyle(.toolBar(toolBarDirection))
        .help(Text("colorPalette", bundle: .module))
        .popover(isPresented: $store.showingColorPopover, arrowEdge: arrowEdge) {
            ColorPalettePopover(
                selectedPaletteIndex: store.canvasState.objectProperties.paletteIndex,
                opacity: store.canvasState.objectProperties.opacity,
                selectColorHandler: { index in
                    await store.send(.colorSelected(index))
                },
                opacityUpdateBeganHandler: {
                    await store.send(.opacityUpdateBegan)
                },
                opacityChangedHandler: { opacity in
                    await store.send(.opacityChanged(opacity))
                }
            )
        }
    }

    var lineWidthButton: some View {
        Button {
            Task {
                await store.send(.lineWidthButtonTapped)
            }
        } label: {
            Image(systemName: "lineweight")
        }
        .buttonStyle(.toolBar(toolBarDirection))
        .help(Text("lineWidth", bundle: .module))
        .popover(isPresented: $store.showingLineWidthPopover, arrowEdge: arrowEdge) {
            LineWidthPopover(
                lineWidth: store.canvasState.objectProperties.lineWidth,
                color: Color.palette(at: store.canvasState.objectProperties.paletteIndex),
                opacity: store.canvasState.objectProperties.opacity,
                lineWidthUpdateBeganHandler: {
                    await store.send(.lineWidthUpdateBegan)
                },
                lineWidthChangedHandler: { lineWidth in
                    await store.send(.lineWidthChanged(lineWidth))
                }
            )
        }
    }

    var arrangeButton: some View {
        Button {
            Task {
                await store.send(.arrangeButtonTapped)
            }
        } label: {
            Image(systemName: "square.3.stack.3d.middle.filled")
        }
        .buttonStyle(.toolBar(toolBarDirection))
        .disabled(store.disabledEditObject)
        .help(Text("arrange", bundle: .module))
        .popover(isPresented: $store.showingArrangePopover, arrowEdge: arrowEdge) {
            ObjectArrangePopover(toolBarDirection: toolBarDirection) { arrangeMethod in
                await store.send(.arrangeSelected(arrangeMethod))
            }
        }
    }

    var alignButton: some View {
        Button {
            Task {
                await store.send(.alignButtonTapped)
            }
        } label: {
            Image(systemName: AlignMethod.horizontalAlignLeft.symbolName)
        }
        .buttonStyle(.toolBar(toolBarDirection))
        .disabled(store.disabledEditObject)
        .help(Text("align", bundle: .module))
        .popover(isPresented: $store.showingAlignPopover, arrowEdge: arrowEdge) {
            ObjectAlignPopover(toolBarDirection: toolBarDirection) { alignMethod in
                await store.send(.alignSelected(alignMethod))
            }
        }
    }

    var flipButton: some View {
        Button {
            Task {
                await store.send(.flipButtonTapped)
            }
        } label: {
            Image(systemName: FlipMethod.flipHorizontal.symbolName)
        }
        .buttonStyle(.toolBar(toolBarDirection))
        .disabled(store.disabledEditObject)
        .help(Text("flip", bundle: .module))
        .popover(isPresented: $store.showingFlipPopover, arrowEdge: arrowEdge) {
            ObjectFlipPopover(toolBarDirection: toolBarDirection) { flipMethod in
                await store.send(.flipSelected(flipMethod))
            }
        }
    }

    var rotateButton: some View {
        Button {
            Task {
                await store.send(.rotateButtonTapped)
            }
        } label: {
            Image(systemName: RotateMethod.rotateRight.symbolName)
        }
        .buttonStyle(.toolBar(toolBarDirection))
        .disabled(store.disabledEditObject)
        .help(Text("rotate", bundle: .module))
        .popover(isPresented: $store.showingRotatePopover, arrowEdge: arrowEdge) {
            ObjectRotatePopover(toolBarDirection: toolBarDirection) { rotateMethod in
                await store.send(.rotateSelected(rotateMethod))
            }
        }
    }

    var duplicateButton: some View {
        Button {
            Task {
                await store.send(.duplicateButtonTapped)
            }
        } label: {
            Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
        }
        .buttonStyle(.toolBar(toolBarDirection))
        .disabled(store.disabledEditObject)
        .help(Text("duplicate", bundle: .module))
    }

    var deleteButton: some View {
        Button {
            Task {
                await store.send(.deleteButtonTapped)
            }
        } label: {
            Image(systemName: "trash.fill")
        }
        .buttonStyle(.toolBar(toolBarDirection))
        .disabled(store.disabledEditObject)
        .help(Text("delete", bundle: .module))
    }

    var clearButton: some View {
        Button {
            Task {
                await store.send(.clearButtonTapped)
            }
        } label: {
            Image(systemName: "rays")
        }
        .buttonStyle(.toolBar(toolBarDirection))
        .disabled(store.disabledWhileInputtingText)
        .help(Text("clear", bundle: .module))
    }

    var shortcutDummyButtons: some View {
        Group {
            dummyButton {
                await store.send(.selectAllButtonTapped)
            }
            .keyboardShortcut("a", modifiers: .command)
            dummyButton {
                await store.send(.deleteButtonTapped)
            }
            .keyboardShortcut(.delete, modifiers: [])
            .disabled(store.disabledEditObject)
            dummyButton {
                await store.send(.clearButtonTapped)
            }
            .keyboardShortcut(.delete, modifiers: .command)
        }
    }

    private func dummyButton(actionHandler: @escaping () async -> Void) -> some View {
        Button {
            Task {
                await actionHandler()
            }
        } label: {
            EmptyView()
        }
    }
}
