import DataSource
import Model
import SwiftUI

struct CanvasSettingsView: View {
    @StateObject var store: CanvasSettings

    private let backgrounds: [Color] = [.white, .black]

    var body: some View {
        Form {
            LabeledContent {
                Toggle(isOn: Binding(
                    get: { store.clearAllObjects },
                    asyncSet: { await store.send(.clearAllObjectsToggleSwitched($0)) }
                )) {
                    Text("clearAllObjects", bundle: .module)
                }
            } label: {
                Text("objects:", bundle: .module)
            }
            Picker(
                selection: Binding(
                    get: { store.defaultObjectType },
                    asyncSet: { await store.send(.defaultObjectTypePickerSelected($0)) }
                )
            ) {
                ForEach(ObjectType.defaultObjects) { objectType in
                    Label {
                        Text(objectType.label, bundle: .module)
                    } icon: {
                        Image(systemName: objectType.symbolName)
                    }
                    .labelStyle(.titleAndIcon)
                    .tag(objectType)
                }
            } label: {
                Text("defaultObjectType:", bundle: .module)
                EmptyView()
            }
            .pickerStyle(.menu)
            .fixedSize(horizontal: true, vertical: false)
            Divider()
            LabeledContent {
                Button("dummy") {
                    Task { await store.send(.colorPopoverPresented(true)) }
                }
                .buttonStyle(.color(Color.palette(at: store.defaultColorIndex)))
                .popover(
                    isPresented: Binding(
                        get: { store.showColorPopover },
                        asyncSet: { await store.send(.colorPopoverPresented($0)) }
                    ),
                    arrowEdge: .bottom
                ) {
                    colorPopover
                }
            } label: {
                Text("defaultColor:", bundle: .module)
            }
            Slider(
                value: Binding(
                    get: { store.defaultOpacity },
                    asyncSet: { await store.send(.defaultOpacityChanged($0)) }
                ),
                in: (0.2 ... 1.0)
            ) {
                Text("defaultOpacity:", bundle: .module)
            } minimumValueLabel: {
                Text(String(format: "%4.1f", store.defaultOpacity))
                    .font(.system(.body, design: .monospaced))
            } maximumValueLabel: {
                Text(Image(systemName: "checkerboard.rectangle"))
                    .foregroundColor(Color.primary.opacity(store.defaultOpacity))
            } onEditingChanged: { editing in
                if !editing {
                    Task { await store.send(.defaultOpacityCommitted) }
                }
            }
            HStack(spacing: 0) {
                Slider(
                    value: Binding(
                        get: { store.defaultLineWidth },
                        asyncSet: { await store.send(.defaultLineWidthChanged($0)) }
                    ),
                    in: (1 ... 20)
                ) {
                    Text("defaultLineWidth:", bundle: .module)
                } minimumValueLabel: {
                    Text(String(format: "%4.1f", store.defaultLineWidth))
                        .font(.system(.body, design: .monospaced))
                } maximumValueLabel: {
                    Text(verbatim: "")
                        .foregroundColor(.clear)
                } onEditingChanged: { editing in
                    if !editing {
                        Task { await store.send(.defaultLineWidthCommitted) }
                    }
                }
                Rectangle()
                    .foregroundColor(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .frame(height: store.defaultLineWidth)
                            .foregroundColor(Color.secondary)
                    )
                    .frame(width: 18, height: 20)
            }
            Divider()
            LabeledContent {
                HStack(alignment: .center, spacing: 8) {
                    ForEach(backgrounds.indices, id: \.self) { index in
                        Button("dummy") {
                            Task { await store.send(.backgroundColorSelected(index)) }
                        }
                        .buttonStyle(.selectableColor(
                            color: backgrounds[index],
                            selection: store.backgroundColorIndex == index
                        ))
                    }
                }
                .fixedSize()
            } label: {
                Text("backgroundColor:", bundle: .module)
            }
            Slider(
                value: Binding(
                    get: { store.backgroundOpacity },
                    asyncSet: { await store.send(.backgroundOpacityChanged($0)) }
                ),
                in: (0.02 ... 1.0)
            ) {
                Text("backgroundOpacity:", bundle: .module)
            } minimumValueLabel: {
                Text(String(format: "%4.2f", store.backgroundOpacity))
                    .font(.system(.body, design: .monospaced))
            } maximumValueLabel: {
                Text(Image(systemName: "checkerboard.rectangle"))
                    .foregroundColor(Color.primary.opacity(store.backgroundOpacity))
            } onEditingChanged: { editing in
                if !editing {
                    Task { await store.send(.backgroundOpacityCommitted) }
                }
            }
        }
        .formStyle(.columns)
        .fixedSize()
        .task {
            await store.send(.task(String(describing: Self.self)))
        }
    }

    private var colorPopover: some View {
        HStack(spacing: 4) {
            ForEach(Color.palette.indices, id: \.self) { column in
                VStack(spacing: 4) {
                    ForEach(Color.palette[column].indices, id: \.self) { row in
                        let index = column + 8 * row
                        Button {
                            Task { await store.send(.defaultColorSelected(index)) }
                        } label: {
                            EmptyView()
                        }
                        .buttonStyle(.colorPalette(
                            color: Color.palette[column][row],
                            selection: store.defaultColorIndex == index
                        ))
                    }
                }
            }
        }
        .padding(8)
    }
}

extension CanvasSettings: ObservableObject {}
