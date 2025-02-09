/*
 CanvasView.swift
 ScreenNote

 Created by Takuto Nakamura on 2023/01/31.
 Copyright © 2023 Studio Kyome. All rights reserved.
*/

import SwiftUI

struct CanvasView<CVM: CanvasViewModel>: View {
    @StateObject var viewModel: CVM
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            Canvas { context, size in
                viewModel.objects.forEach { object in
                    switch object.type {
                    case .select:
                        break
                    case .text:
                        if object.isHidden { break }
                        let bounds = object.bounds
                        let offset = object.textOffset(from: bounds)
                        let orientation = object.textOrientation
                        context.translateBy(x: offset.x, y: offset.y)
                        context.scaleBy(x: orientation.scale, y: 1.0)
                        context.rotate(by: orientation.angle)
                        context.draw(
                            Text(object.text)
                                .foregroundColor(object.color)
                                .font(.system(size: object.fontSize)),
                            in: object.textRect(from: bounds)
                        )
                        context.rotate(by: -orientation.angle)
                        context.scaleBy(x: orientation.scale, y: 1.0)
                        context.translateBy(x: -offset.x, y: -offset.y)
                    case .pen:
                        if let strokeStyle = object.strokeStyle {
                            context.stroke(object.path, with: .color(object.color), style: strokeStyle)
                        } else {
                            context.fill(object.path, with: .color(object.color))
                        }
                    case .line, .lineRect, .lineOval:
                        if let strokeStyle = object.strokeStyle {
                            context.stroke(object.path, with: .color(object.color), style: strokeStyle)
                        } else {
                            fatalError("strokeStyle is not nil")
                        }
                    case .arrow, .fillRect, .fillOval:
                        context.fill(object.path, with: .color(object.color))
                    }
                }
                if let bounds = viewModel.selectedObjectsBounds {
                    context.stroke(Path(bounds), with: .color(.gray), lineWidth: 1)
                    Path.anchorPaths(bounds: bounds).forEach { path in
                        context.fill(path, with: .color(.gray))
                    }
                }
                if let object = viewModel.rectangleForSelection {
                    context.stroke(object.path,
                                   with: .color(Color(.dashWhite)),
                                   style: StrokeStyle(lineWidth: 2, dash: [10.0, 30.0]))
                    context.stroke(object.path,
                                   with: .color(Color(.dashBlack)),
                                   style: StrokeStyle(lineWidth: 2, dash: [10.0, 30.0], dashPhase: 20.0))
                }
            }
            if let properties = viewModel.inputTextProperties {
                TextField(" ", text: $viewModel.inputText)
                    .textFieldStyle(.plain)
                    .foregroundColor(viewModel.textColor)
                    .font(.system(size: properties.fontSize))
                    .lineLimit(1)
                    .fixedSize()
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.accentColor, lineWidth: 4.0)
                            .opacity(0.5)
                            .padding(-4.0)
                    )
                    .offset(properties.inputTextOffset)
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }
                    .onSubmit {
                        viewModel.endEditing(inputTextObject: properties.object,
                                            fontSize: properties.fontSize)
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    if viewModel.dragging {
                        viewModel.dragMoved(startLocation: value.startLocation,
                                           location: value.location)
                    } else {
                        viewModel.dragging = true
                        viewModel.dragBegan(location: value.startLocation)
                    }
                })
                .onEnded({ value in
                    viewModel.dragEnded(startLocation: value.startLocation,
                                       location: value.location)
                    viewModel.dragging = false
                })
        )
    }
}

#Preview {
    CanvasView(viewModel: PreviewMock.CanvasViewModelMock())
}
