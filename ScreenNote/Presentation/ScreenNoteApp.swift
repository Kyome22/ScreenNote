/*
  ScreenNoteApp.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI

@main
struct ScreenNoteApp: App {
    typealias GVMConcrete = GeneralSettingsViewModelImpl<UserDefaultsRepositoryImpl, LaunchAtLoginRepositoryImpl>
    typealias CVMConcrete = CanvasSettingsViewModelImpl<UserDefaultsRepositoryImpl>
    @StateObject private var appModel = ScreenNoteAppModelImpl()

    var body: some Scene {
        Settings {
            SettingsView<ScreenNoteAppModelImpl, GVMConcrete, CVMConcrete>()
                .environmentObject(appModel)
        }
    }
}
