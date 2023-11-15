/*
  CanvasView.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/31.
  
*/

import SwiftUI

struct CanvasView<OM: ObjectModel>: View {
    @ObservedObject private var objectModel: OM

    @State private var dragging: Bool = false
    @FocusState private var isFocused: Bool

    init(_ objectModel: OM) {
        self.objectModel = objectModel
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Canvas { context, size in
                objectModel.objects.forEach { object in
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
                if let bounds = objectModel.selectedObjectsBounds {
                    context.stroke(Path(bounds), with: .color(.gray), lineWidth: 1)
                    Path.anchorPaths(bounds: bounds).forEach { path in
                        context.fill(path, with: .color(.gray))
                    }
                }
                if let object = objectModel.rectangleForSelection {
                    context.stroke(object.path,
                                   with: .color(Color(.dashWhite)),
                                   style: StrokeStyle(lineWidth: 2, dash: [10.0, 30.0]))
                    context.stroke(object.path,
                                   with: .color(Color(.dashBlack)),
                                   style: StrokeStyle(lineWidth: 2, dash: [10.0, 30.0], dashPhase: 20.0))
                }
            }
            if let textObject = objectModel.objectForInputText {
                TextField(" ", text: $objectModel.inputText)
                    .textFieldStyle(.plain)
                    .foregroundColor(objectModel.color.opacity(objectModel.opacity))
                    .font(.system(size: objectModel.fontSize))
                    .lineLimit(1)
                    .fixedSize()
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.accentColor, lineWidth: 4.0)
                            .opacity(0.5)
                            .padding(-4.0)
                    )
                    .offset(textObject.inputTextOffset(from: textObject.bounds))
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }
                    .onSubmit {
                        objectModel.endEditing(textObject)
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    if !dragging {
                        dragging = true
                        objectModel.dragBegan(location: value.startLocation)
                    } else {
                        objectModel.dragMoved(startLocation: value.startLocation,
                                              location: value.location)
                    }
                })
                .onEnded({ value in
                    objectModel.dragEnded(startLocation: value.startLocation,
                                          location: value.location)
                    dragging = false
                })
        )
    }
}

struct CanvasView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasView(PreviewMock.ObjectModelMock())
    }
}
