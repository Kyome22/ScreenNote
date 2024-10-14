/*
  VerticalToolBar.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/02.
  
*/

import SwiftUI

struct VerticalToolBar<TBM: ToolBarModel>: View {
    @StateObject var toolBarModel: TBM

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                Button {
                    toolBarModel.undo()
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward.fill")
                }
                .buttonStyle(.toolBar(.vertical))
                .help("goBack")
                .keyboardShortcut("z", modifiers: .command)
                .disabled(toolBarModel.disabledWhileInputingText)
                Button {
                    toolBarModel.redo()
                } label: {
                    Image(systemName: "arrowshape.turn.up.forward.fill")
                }
                .buttonStyle(.toolBar(.vertical))
                .help("goForward")
                .keyboardShortcut("z", modifiers: [.shift, .command])
                .disabled(toolBarModel.disabledWhileInputingText)
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    objectTypeButton(.text)
                        .keyboardShortcut("t", modifiers: [])
                    objectTypeButton(.pen)
                        .keyboardShortcut("p", modifiers: [])
                }
                HStack(spacing: 8) {
                    objectTypeButton(.line)
                        .keyboardShortcut("l", modifiers: [])
                    objectTypeButton(.arrow)
                        .keyboardShortcut("a", modifiers: [])
                }
                HStack(spacing: 8) {
                    objectTypeButton(.fillRect)
                        .keyboardShortcut("r", modifiers: [])
                    objectTypeButton(.lineRect)
                        .keyboardShortcut("R", modifiers: [.shift])
                }
                HStack(spacing: 8) {
                    objectTypeButton(.fillOval)
                        .keyboardShortcut("o", modifiers: [])
                    objectTypeButton(.lineOval)
                        .keyboardShortcut("O", modifiers: [.shift])
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    objectTypeButton(.select)
                        .keyboardShortcut("s", modifiers: [])
                    Button {
                        toolBarModel.showColorPopover = true
                    } label: {
                        Image(systemName: "drop.fill")
                            .foregroundColor(toolBarModel.color)
                            .opacity(toolBarModel.opacity)
                    }
                    .buttonStyle(.toolBar(.vertical))
                    .help("colorPalette")
                    .popover(
                        isPresented: $toolBarModel.showColorPopover,
                        arrowEdge: toolBarModel.arrowEdge
                    ) {
                        ColorPalettePopover(
                            color: Binding<Color>(
                                get: { toolBarModel.color },
                                set: { toolBarModel.updateColor($0) }
                            ),
                            opacity: Binding<CGFloat>(
                                get: { toolBarModel.opacity },
                                set: { toolBarModel.updateOpacity($0) }
                            ),
                            colors: toolBarModel.colors,
                            startUpdatingOpacityHandler: {
                                toolBarModel.startUpdatingOpacity()
                            }
                        )
                    }
                }
                HStack(spacing: 8) {
                    Button {
                        toolBarModel.showLineWidthPopover = true
                    } label: {
                        Image(systemName: "lineweight")
                    }
                    .buttonStyle(.toolBar(.vertical))
                    .help("lineWidth")
                    .popover(
                        isPresented: $toolBarModel.showLineWidthPopover,
                        arrowEdge: toolBarModel.arrowEdge
                    ) {
                        LineWidthPopover(
                            lineWidth: Binding<CGFloat>(
                                get: { toolBarModel.lineWidth },
                                set: { toolBarModel.updateLineWidth($0) }
                            ),
                            color: toolBarModel.color,
                            opacity: toolBarModel.opacity,
                            startUpdatingLineWidthHandler: {
                                toolBarModel.startUpdatingLineWidth()
                            }
                        )
                    }
                    Button {
                        toolBarModel.showArrangePopover = true
                    } label: {
                        Image(systemName: "square.3.stack.3d.middle.filled")
                    }
                    .buttonStyle(.toolBar(.vertical))
                    .disabled(toolBarModel.disabledEditObject)
                    .help("arrange")
                    .popover(
                        isPresented: $toolBarModel.showArrangePopover,
                        arrowEdge: toolBarModel.arrowEdge
                    ) {
                        ObjectArrangePopover(
                            toolBarDirection: .vertical,
                            arrangeHandler: { arrangeMethod in
                                toolBarModel.arrange(arrangeMethod)
                            }
                        )
                    }
                }
                HStack(spacing: 8) {
                    Button {
                        toolBarModel.showAlignPopover = true
                    } label: {
                        Image(systemName: "align.horizontal.left.fill")
                    }
                    .buttonStyle(.toolBar(.vertical))
                    .disabled(toolBarModel.disabledEditObject)
                    .help("align")
                    .popover(
                        isPresented: $toolBarModel.showAlignPopover,
                        arrowEdge: toolBarModel.arrowEdge
                    ) {
                        ObjectAlignPopover(
                            toolBarDirection: .vertical,
                            alignHandler: { alignMethod in
                                toolBarModel.align(alignMethod)
                            }
                        )
                    }
                    Button {
                        toolBarModel.showFlipPopover = true
                    } label: {
                        Image(systemName: FlipMethod.flipHorizontal.symbolName)
                    }
                    .buttonStyle(.toolBar(.vertical))
                    .disabled(toolBarModel.disabledEditObject)
                    .help("flip")
                    .popover(
                        isPresented: $toolBarModel.showFlipPopover,
                        arrowEdge: toolBarModel.arrowEdge
                    ) {
                        ObjectFlipPopover(
                            toolBarDirection: .vertical,
                            flipHandler: { flipMethod in
                                toolBarModel.flip(flipMethod)
                            }
                        )
                    }
                }
                HStack(spacing: 8) {
                    Button {
                        toolBarModel.showRotatePopover = true
                    } label: {
                        Image(systemName: RotateMethod.rotateRight.symbolName)
                    }
                    .buttonStyle(.toolBar(.vertical))
                    .disabled(toolBarModel.disabledEditObject)
                    .help("rotate")
                    .popover(
                        isPresented: $toolBarModel.showRotatePopover,
                        arrowEdge: toolBarModel.arrowEdge
                    ) {
                        ObjectRotatePopover(
                            toolBarDirection: .vertical,
                            rotateHandler: { rotateMethod in
                                toolBarModel.rotate(rotateMethod)
                            }
                        )
                    }
                    Button {
                        toolBarModel.duplicateSelectedObjects()
                    } label: {
                        Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
                    }
                    .buttonStyle(.toolBar(.vertical))
                    .disabled(toolBarModel.disabledEditObject)
                    .help("duplicate")
                }
                HStack(spacing: 8) {
                    Button {
                        toolBarModel.delete()
                    } label: {
                        Image(systemName: "trash.fill")
                    }
                    .buttonStyle(.toolBar(.vertical))
                    .disabled(toolBarModel.disabledEditObject)
                    .help("delete")
                    Button {
                        toolBarModel.clear()
                    } label: {
                        Image(systemName: "rays")
                    }
                    .buttonStyle(.toolBar(.vertical))
                    .disabled(toolBarModel.disabledWhileInputingText)
                    .help("clear")
                }
            }
            // Dummy Buttons for Keyboard Shortcut
            VStack(alignment: .leading, spacing: 8) {
                dummyButton {
                    toolBarModel.selectAll()
                }
                .keyboardShortcut("a", modifiers: .command)
                .disabled(toolBarModel.disabledSelectAll)
                dummyButton {
                    toolBarModel.delete()
                }
                .keyboardShortcut(.delete, modifiers: [])
                .disabled(toolBarModel.disabledEditObject)
                dummyButton {
                    toolBarModel.clear()
                }
                .keyboardShortcut(.delete, modifiers: .command)
            }
            .overlay(Rectangle())
            .opacity(0)
        }
        .padding(.vertical, 8)
        .frame(width: 80)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
    }

    private func objectTypeButton(_ objectType: ObjectType) -> some View {
        Button {
            toolBarModel.updateObjectType(objectType)
        } label: {
            Image(systemName: objectType.symbolName)
        }
        .buttonStyle(.toolBarRadio(.vertical, Binding(
            get: { toolBarModel.objectType == objectType },
            set: { _, _ in }
        )))
        .help(objectType.label)
    }

    private func dummyButton(actionHandler: @escaping () -> Void) -> some View {
        Button(action: {
            actionHandler()
        }, label: {
            EmptyView()
        })
    }
}

#Preview {
    VerticalToolBar(toolBarModel: PreviewMock.ToolBarModelMock())
}
