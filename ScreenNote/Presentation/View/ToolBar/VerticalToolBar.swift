/*
  VerticalToolBar.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/02.
  
*/

import SwiftUI

struct VerticalToolBar<OM: ObjectModel>: View {
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
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                Button {
                    objectModel.undo()
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward.fill")
                }
                .buttonStyle(.toolBar(.vertical))
                .help("goBack")
                .keyboardShortcut("z", modifiers: .command)
                .disabled(objectModel.objectType == .text)
                Button {
                    objectModel.redo()
                } label: {
                    Image(systemName: "arrowshape.turn.up.forward.fill")
                }
                .buttonStyle(.toolBar(.vertical))
                .help("goForward")
                .keyboardShortcut("z", modifiers: [.shift, .command])
                .disabled(objectModel.objectType == .text)
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    objectTypeButton(.select)
                        .keyboardShortcut("s", modifiers: [])
                    objectTypeButton(.text)
                        .keyboardShortcut("t", modifiers: [])
                }
                HStack(spacing: 8) {
                    objectTypeButton(.pen)
                        .keyboardShortcut("p", modifiers: [])
                    objectTypeButton(.line)
                        .keyboardShortcut("l", modifiers: [])
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
                    Button {
                        showColorPopover = true
                    } label: {
                        Image(systemName: "drop.fill")
                            .foregroundColor(objectModel.color)
                            .opacity(objectModel.opacity)
                    }
                    .buttonStyle(.toolBar(.vertical))
                    .help("colorPalette")
                    .popover(isPresented: $showColorPopover, arrowEdge: arrowEdge) {
                        ColorPalettePopover(
                            color: $objectModel.color,
                            opacity: $objectModel.opacity,
                            colors: objectModel.colors,
                            startUpdatingOpacityHandler: {
                                objectModel.startUpdatingOpacity()
                            }
                        )
                    }
                    Button {
                        showLineWidthPopover = true
                    } label: {
                        Image(systemName: "lineweight")
                    }
                    .buttonStyle(.toolBar(.vertical))
                    .help("lineWidth")
                    .popover(isPresented: $showLineWidthPopover, arrowEdge: arrowEdge) {
                        LineWidthPopover(
                            lineWidth: $objectModel.lineWidth,
                            color: $objectModel.color,
                            opacity: $objectModel.opacity,
                            startUpdatingLineWidthHandler: {
                                objectModel.startUpdatingLineWidth()
                            }
                        )
                    }
                }
                HStack(spacing: 8) {
                    Button {
                        showArrangePopover = true
                    } label: {
                        Image(systemName: "square.3.stack.3d.middle.filled")
                    }
                    .buttonStyle(.toolBar(.vertical))
                    .help("arrange")
                    .popover(isPresented: $showArrangePopover, arrowEdge: arrowEdge) {
                        ObjectArrangePopover(
                            toolBarDirection: .vertical,
                            arrangeHandler: { arrangeMethod in
                                objectModel.arrange(arrangeMethod)
                            }
                        )
                    }
                    Button {
                        showAlignPopover = true
                    } label: {
                        Image(systemName: "align.horizontal.left.fill")
                    }
                    .buttonStyle(.toolBar(.vertical))
                    .help("align")
                    .popover(isPresented: $showAlignPopover, arrowEdge: arrowEdge) {
                        ObjectAlignPopover(
                            toolBarDirection: .vertical,
                            alignHandler: { alignment in
                                objectModel.align(alignment)
                            }
                        )
                    }
                }
                HStack(spacing: 8) {
                    Button {
                        showFlipPopover = true
                    } label: {
                        Image(systemName: ObjectFlipDirection.horizontal.symbolName)
                    }
                    .buttonStyle(.toolBar(.vertical))
                    .help("flip")
                    .popover(isPresented: $showFlipPopover, arrowEdge: arrowEdge) {
                        ObjectFlipPopover(
                            toolBarDirection: .vertical,
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
                    .buttonStyle(.toolBar(.vertical))
                    .help("rotate")
                    .popover(isPresented: $showRotatePopover) {
                        ObjectRotatePopover(
                            toolBarDirection: .vertical,
                            rotateHandler: { rotateDirection in
                                objectModel.rotate(rotateDirection)
                            }
                        )
                    }
                }
                HStack(spacing: 8) {
                    Button {
                        objectModel.duplicateSelectedObjects()
                    } label: {
                        Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
                    }
                    .buttonStyle(.toolBar(.vertical))
                    .help("duplicate")
                    Button {
                        objectModel.delete()
                    } label: {
                        Image(systemName: "trash.fill")
                    }
                    .buttonStyle(.toolBar(.vertical))
                    .help("delete")
                }
            }
            // Dummy Buttons for Keyboard Shortcut
            VStack(alignment: .leading, spacing: 8) {
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
        .padding(.vertical, 8)
        .frame(width: 80)
        .frame(maxHeight: .infinity, alignment: .top)
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
        .buttonStyle(.toolBarRadio(.vertical, Binding(
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

struct VerticalToolBar_Previews: PreviewProvider {
    static var previews: some View {
        VerticalToolBar(PreviewMock.ObjectModelMock(), arrowEdge: .trailing)
    }
}
