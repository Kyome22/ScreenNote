import DataSource
import Model
import SwiftUI

struct CanvasView: View {
    var store: Workspace
    @FocusState private var isFocused: Bool
    @State private var dragging = false

    private var textColor: Color {
        Color.palette(at: store.canvasState.objectProperties.paletteIndex)
            .opacity(store.canvasState.objectProperties.opacity)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Canvas { context, _ in
                store.canvasState.objects.forEach { object in
                    draw(object, in: &context)
                }
                if let bounds = store.canvasState.selectedObjectsBounds {
                    context.stroke(Path(bounds), with: .color(.gray), lineWidth: 1)
                    Anchor.rects(bounds: bounds).forEach { rect in
                        context.fill(Path(rect), with: .color(.gray))
                    }
                }
                if let object = store.canvasState.rectangleForSelection {
                    context.stroke(
                        object.path,
                        with: .color(Color("DashWhite", bundle: .module)),
                        style: StrokeStyle(lineWidth: 2, dash: [10.0, 30.0])
                    )
                    context.stroke(
                        object.path,
                        with: .color(Color("DashBlack", bundle: .module)),
                        style: StrokeStyle(lineWidth: 2, dash: [10.0, 30.0], dashPhase: 20.0)
                    )
                }
            }
            if let properties = store.canvasState.inputTextProperties {
                TextField(
                    " ",
                    text: Binding(
                        get: { store.inputText },
                        asyncSet: { await store.send(.inputTextChanged($0)) }
                    )
                )
                .textFieldStyle(.plain)
                .foregroundColor(textColor)
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
                    Task { await store.send(.inputTextSubmitted) }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if dragging {
                        Task { await store.send(.dragMoved(value.startLocation, value.location)) }
                    } else {
                        dragging = true
                        Task { await store.send(.dragBegan(value.startLocation)) }
                    }
                }
                .onEnded { value in
                    dragging = false
                    Task { await store.send(.dragEnded(value.startLocation, value.location)) }
                }
        )
    }

    private func draw(_ object: Object, in context: inout GraphicsContext) {
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
        default:
            if let strokeStyle = object.strokeStyle {
                context.stroke(object.path, with: .color(object.color), style: strokeStyle)
            } else {
                context.fill(object.path, with: .color(object.color))
            }
        }
    }
}
