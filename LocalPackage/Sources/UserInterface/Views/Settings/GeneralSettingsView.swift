import DataSource
import Model
import SpiceKey
import SwiftUI

struct GeneralSettingsView: View {
    @StateObject var store: GeneralSettings

    var body: some View {
        Form {
            Section {
                Picker(selection: Binding(
                    get: { store.triggerMethod },
                    asyncSet: { await store.send(.triggerMethodPickerSelected($0)) }
                )) {
                    ForEach(TriggerMethod.allCases) { method in
                        Text(method.label).tag(method)
                    }
                } label: {
                    Text("triggerMethod", bundle: .module)
                }
                .pickerStyle(.radioGroup)

                Picker(selection: Binding(
                    get: { store.modifierFlag },
                    asyncSet: { await store.send(.modifierFlagPickerSelected($0)) }
                )) {
                    ForEach(ModifierFlag.allCases) { modifierFlag in
                        Text(modifierFlag.label).tag(modifierFlag)
                    }
                } label: {
                    Label {
                        Text("modifierKey", bundle: .module)
                    } icon: {
                        Image(systemName: "circle")
                            .foregroundStyle(Color.clear)
                    }
                }
                .pickerStyle(.menu)

                Slider(value: $store.longPressDuration, in: 0.5 ... 1.5) {
                    Label {
                        Text("longPressDuration", bundle: .module)
                    } icon: {
                        Image(systemName: "circle")
                            .foregroundStyle(Color.clear)
                    }
                } minimumValueLabel: {
                    Text(verbatim: "")
                        .foregroundStyle(.clear)
                } maximumValueLabel: {
                    Text("\(store.longPressDuration)s", bundle: .module)
                        .font(.system(.body, design: .monospaced))
                } onEditingChanged: { editing in
                    Task {
                        await store.send(.longPressDurationChanged(editing))
                    }
                }
                .disabled(store.triggerMethod != .longPressKey)
            }

            Section {
                Picker(selection: Binding(
                    get: { store.toolBarPosition },
                    asyncSet: { await store.send(.toolBarPositionPickerSelected($0)) }
                )) {
                    ForEach(ToolBarPosition.allCases) { position in
                        Text(position.label).tag(position)
                    }
                } label: {
                    Text("toolBarPosition", bundle: .module)
                }
                .pickerStyle(.menu)
            }

            Section {
                LabeledContent {
                    Toggle(isOn: Binding(
                        get: { store.launchesAtLogin },
                        asyncSet: { await store.send(.launchAtLoginToggleSwitched($0)) }
                    )) {
                        Text("launchAtLogin", bundle: .module)
                    }
                } label: {
                    Text("launch", bundle: .module)
                }

                LabeledContent {
                    Toggle(isOn: Binding(
                        get: { store.showsTriggerMethod },
                        asyncSet: { await store.send(.showTriggerMethodToggleSwitched($0)) }
                    )) {
                        Text("showTriggerMethod", bundle: .module)
                    }
                } label: {
                    Text("introduction", bundle: .module)
                }
            }
        }
        .formStyle(.grouped)
        .task {
            await store.send(.task(String(describing: Self.self)))
        }
    }
}

extension GeneralSettings: ObservableObject {}
