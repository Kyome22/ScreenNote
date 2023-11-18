/*
  ScreenNoteApp.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI

@main
struct ScreenNoteApp: App {
    typealias SAM = ScreenNoteAppModelImpl
    @StateObject private var appModel = SAM()

    var body: some Scene {
        Settings {
            SettingsView<SAM>()
                .environmentObject(appModel)
        }
        MenuBarExtra {
            MenuView(viewModel: SAM.MVM(appModel.windowModel))
        } label: {
            Image(.statusIcon)
                .environment(\.displayScale, 2.0)
        }
    }
}
