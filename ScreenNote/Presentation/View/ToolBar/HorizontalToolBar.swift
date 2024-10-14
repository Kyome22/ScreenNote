/*
  HorizontalToolBar.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/31.
  
*/


import SwiftUI

struct HorizontalToolBar<TBM: ToolBarModel>: View {
    @StateObject var toolBarModel: TBM

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            HStack(spacing: 8) {
                Button {
                    toolBarModel.undo()
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward.fill")
                }
                .buttonStyle(.toolBar(.horizontal))
                .help("goBack")
                .keyboardShortcut("z", modifiers: .command)
                .disabled(toolBarModel.disabledWhileInputingText)
                Button {
                    toolBarModel.redo()
                } label: {
                    Image(systemName: "arrowshape.turn.up.forward.fill")
                }
                .buttonStyle(.toolBar(.horizontal))
                .help("goForward")
                .keyboardShortcut("z", modifiers: [.shift, .command])
                .disabled(toolBarModel.disabledWhileInputingText)
            }
            HStack(spacing: 8) {
                objectTypeButton(.text)
                    .keyboardShortcut("t", modifiers: [])
                objectTypeButton(.pen)
                    .keyboardShortcut("p", modifiers: [])
                objectTypeButton(.line)
                    .keyboardShortcut("l", modifiers: [])
                objectTypeButton(.arrow)
                    .keyboardShortcut("a", modifiers: [])
                objectTypeButton(.fillRect)
                    .keyboardShortcut("r", modifiers: [])
                objectTypeButton(.lineRect)
                    .keyboardShortcut("R", modifiers: [.shift])
                objectTypeButton(.fillOval)
                    .keyboardShortcut("o", modifiers: [])
                objectTypeButton(.lineOval)
                    .keyboardShortcut("O", modifiers: [.shift])
            }
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
                .buttonStyle(.toolBar(.horizontal))
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
                Button {
                    toolBarModel.showLineWidthPopover = true
                } label: {
                    Image(systemName: "lineweight")
                }
                .buttonStyle(.toolBar(.horizontal))
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
                .buttonStyle(.toolBar(.horizontal))
                .disabled(toolBarModel.disabledEditObject)
                .help("arrange")
                .popover(
                    isPresented: $toolBarModel.showArrangePopover,
                    arrowEdge: toolBarModel.arrowEdge
                ) {
                    ObjectArrangePopover(
                        toolBarDirection: .horizontal,
                        arrangeHandler: { arrangeMethod in
                            toolBarModel.arrange(arrangeMethod)
                        }
                    )
                }
                Button {
                    toolBarModel.showAlignPopover = true
                } label: {
                    Image(systemName: AlignMethod.horizontalAlignLeft.symbolName)
                }
                .buttonStyle(.toolBar(.horizontal))
                .disabled(toolBarModel.disabledEditObject)
                .help("align")
                .popover(
                    isPresented: $toolBarModel.showAlignPopover,
                    arrowEdge: toolBarModel.arrowEdge
                ) {
                    ObjectAlignPopover(
                        toolBarDirection: .horizontal,
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
                .buttonStyle(.toolBar(.horizontal))
                .disabled(toolBarModel.disabledEditObject)
                .help("flip")
                .popover(
                    isPresented: $toolBarModel.showFlipPopover,
                    arrowEdge: toolBarModel.arrowEdge
                ) {
                    ObjectFlipPopover(
                        toolBarDirection: .horizontal,
                        flipHandler: { flipMethod in
                            toolBarModel.flip(flipMethod)
                        }
                    )
                }
                Button {
                    toolBarModel.showRotatePopover = true
                } label: {
                    Image(systemName: RotateMethod.rotateRight.symbolName)
                }
                .buttonStyle(.toolBar(.horizontal))
                .disabled(toolBarModel.disabledEditObject)
                .help("rotate")
                .popover(
                    isPresented: $toolBarModel.showRotatePopover,
                    arrowEdge: toolBarModel.arrowEdge
                ) {
                    ObjectRotatePopover(
                        toolBarDirection: .horizontal,
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
                .buttonStyle(.toolBar(.horizontal))
                .disabled(toolBarModel.disabledEditObject)
                .help("duplicate")
                Button {
                    toolBarModel.delete()
                } label: {
                    Image(systemName: "trash.fill")
                }
                .buttonStyle(.toolBar(.horizontal))
                .disabled(toolBarModel.disabledEditObject)
                .help("delete")
                Button {
                    toolBarModel.clear()
                } label: {
                    Image(systemName: "rays")
                }
                .buttonStyle(.toolBar(.horizontal))
                .disabled(toolBarModel.disabledWhileInputingText)
                .help("clear")
            }
            // Dummy Buttons for Keyboard Shortcut
            HStack(spacing: 8) {
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
        .padding(.horizontal, 8)
        .frame(height: 40)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
    }

    private func objectTypeButton(_ objectType: ObjectType) -> some View {
        Button {
            toolBarModel.updateObjectType(objectType)
        } label: {
            Image(systemName: objectType.symbolName)
        }
        .buttonStyle(.toolBarRadio(.horizontal, Binding(
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
    HorizontalToolBar(toolBarModel: PreviewMock.ToolBarModelMock())
}
