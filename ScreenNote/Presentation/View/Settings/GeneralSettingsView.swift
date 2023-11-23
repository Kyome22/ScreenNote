/*
  GeneralSettingsView.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SpiceKey
import SwiftUI

struct GeneralSettingsView<GVM: GeneralSettingsViewModel>: View {
    @StateObject var viewModel: GVM

    var body: some View {
        Form {
            Picker(selection: $viewModel.toggleMethod) {
                ForEach(ToggleMethod.allCases, id: \.rawValue) { toggleMethod in
                    Text(toggleMethod.label)
                        .tag(toggleMethod)
                }
            } label: {
                Text("toggleMethod:")
                EmptyView()
            }
            .pickerStyle(.radioGroup)
            Picker(selection: $viewModel.modifierFlag) {
                ForEach(ModifierFlag.allCases, id: \.rawValue) { modifierFlag in
                    Text(modifierFlag.label)
                        .tag(modifierFlag)
                }
            } label: {
                Text("modifierKey:")
                EmptyView()
            }
            .pickerStyle(.menu)
            .fixedSize(horizontal: true, vertical: false)
            Divider()
            Picker(selection: $viewModel.toolBarPosition) {
                ForEach(ToolBarPosition.allCases, id: \.rawValue) { position in
                    Text(position.label)
                        .tag(position)
                }
            } label: {
                Text("toolBarPosition:")
                EmptyView()
            }
            .pickerStyle(.menu)
            .fixedSize(horizontal: true, vertical: false)
            LabeledContent("introduction:") {
                Toggle(isOn: $viewModel.showToggleMethod) {
                    Text("showToggleMethod")
                }
            }
            LabeledContent("launch:") {
                Toggle(isOn: $viewModel.launchAtLogin) {
                    Text("launchAtLogin")
                }
            }
        }
        .formStyle(.columns)
        .fixedSize()
    }
}

#Preview {
    ForEach(["en_US", "ja_JP"], id: \.self) { id in
        GeneralSettingsView(viewModel: PreviewMock.GeneralSettingsViewModelMock())
            .environment(\.locale, .init(identifier: id))
    }
}
