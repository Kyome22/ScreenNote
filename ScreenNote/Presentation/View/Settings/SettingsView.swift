/*
  SettingsView.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI

struct SettingsView<SAM: ScreenNoteAppModel>: View {
    @EnvironmentObject private var appModel: SAM

    var body: some View {
        TabView(selection: $appModel.settingsTab) {
            GeneralSettingsView(viewModel: SAM.GVM(appModel.userDefaultsRepository))
                .tabItem {
                    Label("general", systemImage: "gear")
                }
                .tag(SettingsTabType.general)
            CanvasSettingsView(viewModel: SAM.CsVM(appModel.userDefaultsRepository))
                .tabItem {
                    Label("canvas", systemImage: "square.and.pencil")
                }
                .tag(SettingsTabType.canvas)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
        .accessibilityIdentifier("Settings")
    }
}

#Preview {
    SettingsView<PreviewMock.ScreenNoteAppModelMock>()
        .environmentObject(PreviewMock.ScreenNoteAppModelMock())
}
