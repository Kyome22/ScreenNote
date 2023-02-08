/*
  SettingsView.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI

struct SettingsView<SAM: ScreenNoteAppModel,
                    GVM: GeneralSettingsViewModel>: View {
    @EnvironmentObject private var appModel: SAM

    private enum Tabs: Hashable {
        case general
    }

    var body: some View {
        TabView {
            GeneralSettingsView(viewModel: GVM(appModel.userDefaultsRepository,
                                               appModel.launchAtLoginRepository))
            .tabItem {
                Label("general", systemImage: "gear")
            }
            .tag(Tabs.general)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
        .accessibilityIdentifier("Preferences")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView<PreviewMock.ScreenNoteAppModelMock,
                     PreviewMock.GeneralSettingsViewModelMock>()
            .environmentObject(PreviewMock.ScreenNoteAppModelMock())
    }
}
