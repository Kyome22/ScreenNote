import DataSource
import Model
import SwiftUI

struct CanvasSettingsView: View {
    @StateObject var store: CanvasSettings

    private let backgrounds: [Color] = [.white, .black]

    var body: some View {
        Form {
            Section {
                LabeledContent {
                    Toggle(isOn: Binding(
                        get: { store.clearAllObjects },
                        asyncSet: { await store.send(.clearAllObjectsToggleSwitched($0)) }
                    )) {
                        Text("clearAllObjects", bundle: .module)
                    }
                } label: {
                    Text("canvas", bundle: .module)
                }

                Picker(selection: Binding(
                    get: { store.defaultObjectType },
                    asyncSet: { await store.send(.defaultObjectTypePickerSelected($0)) }
                )) {
                    ForEach(ObjectType.defaultObjects) { objectType in
                        Label {
                            Text(objectType.label)
                        } icon: {
                            Image(systemName: objectType.symbolName)
                        }
                        .labelStyle(.titleAndIcon)
                        .tag(objectType)
                    }
                } label: {
                    Text("defaultObjectType", bundle: .module)
                }
                .pickerStyle(.menu)
            }

            Section {
                LabeledContent {
                    Button {
                        Task {
                            await store.send(.defaultColorButtonTapped)
                        }
                    } label: {
                        EmptyView()
                    }
                    .buttonStyle(.color(Color.palette(at: store.defaultColorIndex)))
                    .popover(isPresented: $store.showingColorPopover, arrowEdge: .bottom) {
                        DefaultColorPopover(currentIndex: store.defaultColorIndex) { index in
                            await store.send(.defaultColorSelected(index))
                        }
                    }
                } label: {
                    Text("defaultColor", bundle: .module)
                }

                Slider(value: $store.defaultOpacity, in: 0.2 ... 1.0) {
                    Text("defaultOpacity", bundle: .module)
                } minimumValueLabel: {
                    Text(String(format: "%4.1f", store.defaultOpacity))
                        .font(.system(.body, design: .monospaced))
                } maximumValueLabel: {
                    Text(Image(systemName: "checkerboard.rectangle"))
                        .foregroundStyle(Color.primary.opacity(store.defaultOpacity))
                } onEditingChanged: { editing in
                    Task {
                        await store.send(.defaultOpacityChanged(editing))
                    }
                }

                HStack(spacing: 2) {
                    Slider(value: $store.defaultLineWidth, in: 1 ... 20) {
                        Text("defaultLineWidth", bundle: .module)
                    } minimumValueLabel: {
                        Text(String(format: "%4.1f", store.defaultLineWidth))
                            .font(.system(.body, design: .monospaced))
                    } maximumValueLabel: {
                        Text(verbatim: "")
                            .foregroundStyle(.clear)
                    } onEditingChanged: { editing in
                        Task {
                            await store.send(.defaultLineWidthChanged(editing))
                        }
                    }
                    Color.clear.frame(width: 16, height: 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .frame(height: store.defaultLineWidth)
                                .foregroundStyle(Color.secondary)
                        )
                }
            }

            Section {
                LabeledContent {
                    HStack(alignment: .center, spacing: 8) {
                        ForEach(backgrounds.indices, id: \.self) { index in
                            Button {
                                Task {
                                    await store.send(.backgroundColorSelected(index))
                                }
                            } label: {
                                EmptyView()
                            }
                            .buttonStyle(.selectableColor(
                                color: backgrounds[index],
                                selection: store.backgroundColorIndex == index
                            ))
                        }
                    }
                } label: {
                    Text("backgroundColor", bundle: .module)
                }

                Slider(value: $store.backgroundOpacity, in: 0.02 ... 1.0) {
                    Text("backgroundOpacity", bundle: .module)
                } minimumValueLabel: {
                    Text(String(format: "%4.2f", store.backgroundOpacity))
                        .font(.system(.body, design: .monospaced))
                } maximumValueLabel: {
                    Text(Image(systemName: "checkerboard.rectangle"))
                        .foregroundStyle(Color.primary.opacity(store.backgroundOpacity))
                } onEditingChanged: { editing in
                    Task {
                        await store.send(.backgroundOpacityChanged(editing))
                    }
                }
            }
        }
        .formStyle(.grouped)
        .task {
            await store.send(.task(String(describing: Self.self)))
        }
    }
}

extension CanvasSettings: ObservableObject {}
