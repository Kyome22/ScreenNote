/*
  SettingsView.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI

struct SettingsView<SAM: ScreenNoteAppModel,
                    GVM: GeneralSettingsViewModel,
                    CVM: CanvasSettingsViewModel>: View {
    @EnvironmentObject private var appModel: SAM

    var body: some View {
        TabView(selection: $appModel.settingsTab) {
            GeneralSettingsView(viewModel: GVM(appModel.userDefaultsRepository,
                                               appModel.launchAtLoginRepository))
            .tabItem {
                Label("general", systemImage: "gear")
            }
            .tag(SettingsTabType.general)
            CanvasSettingsView(viewModel: CVM(appModel.userDefaultsRepository))
                .tabItem {
                    Label("canvas", systemImage: "square.and.pencil")
                }
                .tag(SettingsTabType.canvas)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
        .accessibilityIdentifier("Preferences")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView<PreviewMock.ScreenNoteAppModelMock,
                     PreviewMock.GeneralSettingsViewModelMock,
                     PreviewMock.CanvasSettingsViewModelMock>()
            .environmentObject(PreviewMock.ScreenNoteAppModelMock())
    }
}
