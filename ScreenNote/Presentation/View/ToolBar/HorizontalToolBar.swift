/*
  HorizontalToolBar.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/31.
  
*/


import SwiftUI

struct HorizontalToolBar<OM: ObjectModel>: View {
    @ObservedObject private var objectModel: OM
    @State private var showColorPopover: Bool = false
    @State private var showLineWidthPopover: Bool = false
    @State private var showArrangePopover: Bool = false
    @State private var showAlignPopover: Bool = false
    @State private var showFlipPopover: Bool = false
    @State private var showRotatePopover: Bool = false
    private let arrowEdge: Edge

    init(_ objectModel: OM, arrowEdge: Edge) {
        self.objectModel = objectModel
        self.arrowEdge = arrowEdge
    }

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            HStack(spacing: 8) {
                Button {
                    objectModel.undo()
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward.fill")
                }
                .buttonStyle(.toolBar(.horizontal))
                .help("goBack")
                .keyboardShortcut("z", modifiers: .command)
                .disabled(objectModel.objectType == .text)
                Button {
                    objectModel.redo()
                } label: {
                    Image(systemName: "arrowshape.turn.up.forward.fill")
                }
                .buttonStyle(.toolBar(.horizontal))
                .help("goForward")
                .keyboardShortcut("z", modifiers: [.shift, .command])
                .disabled(objectModel.objectType == .text)
            }
            HStack(spacing: 8) {
                objectTypeButton(.select)
                    .keyboardShortcut("s", modifiers: [])
                objectTypeButton(.text)
                    .keyboardShortcut("t", modifiers: [])
                objectTypeButton(.pen)
                    .keyboardShortcut("p", modifiers: [])
                objectTypeButton(.line)
                    .keyboardShortcut("l", modifiers: [])
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
                Button {
                    showColorPopover = true
                } label: {
                    Image(systemName: "drop.fill")
                        .foregroundColor(objectModel.color)
                        .opacity(objectModel.alpha)
                }
                .buttonStyle(.toolBar(.horizontal))
                .help("colorPalette")
                .popover(isPresented: $showColorPopover, arrowEdge: arrowEdge) {
                    ColorPalettePopover(color: $objectModel.color,
                                        alpha: $objectModel.alpha,
                                        colors: objectModel.colors) {
                        objectModel.willUpdateAlpha()
                    }
                }
                Button {
                    showLineWidthPopover = true
                } label: {
                    Image(systemName: "lineweight")
                }
                .buttonStyle(.toolBar(.horizontal))
                .help("lineWidth")
                .popover(isPresented: $showLineWidthPopover, arrowEdge: arrowEdge) {
                    LineWidthPopover(lineWidth: $objectModel.lineWidth,
                                     color: $objectModel.color,
                                     alpha: $objectModel.alpha) {
                        objectModel.willUpdateLineWidth()
                    }
                }
                Button {
                    showArrangePopover = true
                } label: {
                    Image(systemName: "square.3.stack.3d.middle.filled")
                }
                .buttonStyle(.toolBar(.horizontal))
                .help("arrange")
                .popover(isPresented: $showArrangePopover, arrowEdge: arrowEdge) {
                    ObjectArrangePopover(
                        toolBarDirection: .horizontal,
                        arrangeHandler: { arrangeMethod in
                            objectModel.arrange(arrangeMethod)
                        }
                    )
                }
                Button {
                    showAlignPopover = true
                } label: {
                    Image(systemName: ObjectAlignment.left.symbolName)
                }
                .buttonStyle(.toolBar(.horizontal))
                .help("align")
                .popover(isPresented: $showAlignPopover, arrowEdge: arrowEdge) {
                    ObjectAlignPopover(
                        toolBarDirection: .horizontal,
                        alignHandler: { alignment in
                            objectModel.align(alignment)
                        }
                    )
                }
                Button {
                    showFlipPopover = true
                } label: {
                    Image(systemName: ObjectFlipDirection.horizontal.symbolName)
                }
                .buttonStyle(.toolBar(.horizontal))
                .help("flip")
                .popover(isPresented: $showFlipPopover, arrowEdge: arrowEdge) {
                    ObjectFlipPopover(
                        toolBarDirection: .horizontal,
                        flipHandler: { flipDirection in
                            objectModel.flip(flipDirection)
                        }
                    )
                }
                Button {
                    showRotatePopover = true
                } label: {
                    Image(systemName: ObjectRotateDirection.counterClockwise.symbolName)
                }
                .buttonStyle(.toolBar(.horizontal))
                .help("rotate")
                .popover(isPresented: $showRotatePopover) {
                    ObjectRotatePopover(
                        toolBarDirection: .horizontal,
                        rotateHandler: { rotateDirection in
                            objectModel.rotate(rotateDirection)
                        }
                    )
                }
                Button {
                    objectModel.duplicateSelectedObjects()
                } label: {
                    Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
                }
                .buttonStyle(.toolBar(.horizontal))
                .help("duplicate")
                Button {
                    objectModel.delete()
                } label: {
                    Image(systemName: "trash.fill")
                }
                .buttonStyle(.toolBar(.horizontal))
                .help("delete")
            }
            // Dummy Buttons for Keyboard Shortcut
            HStack(spacing: 8) {
                dummyButton {
                    objectModel.selectAll()
                }
                .keyboardShortcut("a", modifiers: .command)
                .disabled(objectModel.objectType == .text)
                dummyButton {
                    objectModel.delete()
                }
                .keyboardShortcut(.delete, modifiers: [])
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
            withAnimation(.none) {
                objectModel.objectType = objectType
            }
        } label: {
            Image(systemName: objectType.symbolName)
        }
        .buttonStyle(.toolBarRadio(.horizontal, Binding(
            get: { objectModel.objectType == objectType },
            set: { _, _ in }
        )))
        .help(objectType.help)
    }

    private func dummyButton(actionHandler: @escaping () -> Void) -> some View {
        Button(action: {
            withAnimation(.none) {
                actionHandler()
            }
        }, label: {
            EmptyView()
        })
    }
}

struct HorizontalToolBar_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalToolBar(PreviewMock.ObjectModelMock(), arrowEdge: .bottom)
    }
}