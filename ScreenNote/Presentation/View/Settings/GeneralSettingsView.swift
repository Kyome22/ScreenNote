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
        VStack(alignment: .leading, spacing: 8) {
            Text("toggleMethod:")
            Picker(selection: $viewModel.toggleMethod) {
                ForEach(ToggleMethod.allCases, id: \.rawValue) { toggleMethod in
                    Text(toggleMethod.localizedKey)
                        .tag(toggleMethod)
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.radioGroup)
            .padding(.bottom, 8)
            HStack(alignment: .center, spacing: 8) {
                wrapText(maxKey: "wrapTextGeneralTab", key: "modifierKey:")
                Picker(selection: $viewModel.modifierFlag) {
                    ForEach(ModifierFlag.allCases, id: \.rawValue) { modifierFlag in
                        Text(LocalizedStringKey(stringLiteral: "\(modifierFlag.title)Key"))
                            .tag(modifierFlag)
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.menu)
                .fixedSize(horizontal: true, vertical: false)
                Spacer()
            }
            Divider()
            HStack(alignment: .center, spacing: 8) {
                wrapText(maxKey: "wrapTextGeneralTab", key: "toolBarPosition:")
                Picker(selection: $viewModel.toolBarPosition) {
                    ForEach(ToolBarPosition.allCases, id: \.rawValue) { position in
                        Text(position.localizedKey)
                            .tag(position)
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.menu)
                .fixedSize(horizontal: true, vertical: false)
                Spacer()
            }
            Divider()
            HStack(alignment: .center, spacing: 8) {
                wrapText(maxKey: "wrapTextGeneralTab", key: "launch:")
                Toggle(isOn: $viewModel.launchAtLogin) {
                    Text("launchAtLogin")
                }
            }
        }
        .fixedSize()
    }
}

#Preview {
    ForEach(["en_US", "ja_JP"], id: \.self) { id in
        GeneralSettingsView(viewModel: PreviewMock.GeneralSettingsViewModelMock())
            .environment(\.locale, .init(identifier: id))
    }
}
