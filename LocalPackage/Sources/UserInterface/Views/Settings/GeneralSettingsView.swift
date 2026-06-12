import DataSource
import Model
import SpiceKey
import SwiftUI

struct GeneralSettingsView: View {
    @StateObject var store: GeneralSettings

    var body: some View {
        Form {
            Picker(
                selection: Binding(
                    get: { store.toggleMethod },
                    asyncSet: { await store.send(.toggleMethodPickerSelected($0)) }
                )
            ) {
                ForEach(ToggleMethod.allCases) { toggleMethod in
                    radioContent(toggleMethod)
                        .tag(toggleMethod)
                }
            } label: {
                Text("toggleMethod:", bundle: .module)
                EmptyView()
            }
            .pickerStyle(.radioGroup)
            Picker(
                selection: Binding(
                    get: { store.modifierFlag },
                    asyncSet: { await store.send(.modifierFlagPickerSelected($0)) }
                )
            ) {
                ForEach(ModifierFlag.allCases) { modifierFlag in
                    Text(modifierFlag.label)
                        .tag(modifierFlag)
                }
            } label: {
                Text("modifierKey:", bundle: .module)
                EmptyView()
            }
            .pickerStyle(.menu)
            .fixedSize(horizontal: true, vertical: false)
            Divider()
            Picker(
                selection: Binding(
                    get: { store.toolBarPosition },
                    asyncSet: { await store.send(.toolBarPositionPickerSelected($0)) }
                )
            ) {
                ForEach(ToolBarPosition.allCases) { position in
                    Text(position.label, bundle: .module)
                        .tag(position)
                }
            } label: {
                Text("toolBarPosition:", bundle: .module)
                EmptyView()
            }
            .pickerStyle(.menu)
            .fixedSize(horizontal: true, vertical: false)
            LabeledContent {
                Toggle(isOn: Binding(
                    get: { store.showToggleMethod },
                    asyncSet: { await store.send(.showToggleMethodToggleSwitched($0)) }
                )) {
                    Text("showToggleMethod", bundle: .module)
                }
            } label: {
                Text("introduction:", bundle: .module)
            }
            LabeledContent {
                Toggle(isOn: Binding(
                    get: { store.launchAtLogin },
                    asyncSet: { await store.send(.launchAtLoginToggleSwitched($0)) }
                )) {
                    Text("launchAtLogin", bundle: .module)
                }
            } label: {
                Text("launch:", bundle: .module)
            }
        }
        .formStyle(.columns)
        .fixedSize()
        .task {
            await store.send(.task(String(describing: Self.self)))
        }
    }

    private func radioContent(_ toggleMethod: ToggleMethod) -> some View {
        Group {
            switch toggleMethod {
            case .longPressKey:
                LabeledContent {
                    Slider(
                        value: Binding(
                            get: { store.longPressSeconds },
                            asyncSet: { await store.send(.longPressSecondsChanged($0)) }
                        ),
                        in: (0.5 ... 1.5)
                    ) {
                        EmptyView()
                    } minimumValueLabel: {
                        Text(verbatim: "")
                            .foregroundColor(.clear)
                    } maximumValueLabel: {
                        Text("\(store.longPressSeconds)s", bundle: .module)
                            .font(.system(.body, design: .monospaced))
                    } onEditingChanged: { editing in
                        if !editing {
                            Task { await store.send(.longPressSecondsCommitted) }
                        }
                    }
                    .controlSize(.small)
                } label: {
                    Text(toggleMethod.label, bundle: .module)
                }
            case .pressBothSideKeys:
                Text(toggleMethod.label, bundle: .module)
            }
        }
    }
}

extension GeneralSettings: ObservableObject {}
