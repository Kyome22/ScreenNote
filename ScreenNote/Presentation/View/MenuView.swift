/*
 MenuView.swift
 ScreenNote

 Created by Takuto Nakamura on 2023/11/18.
 Copyright © 2023 Studio Kyome. All rights reserved.
*/

import SwiftUI

struct MenuView<MVM: MenuViewModel>: View {
    @StateObject var viewModel: MVM

    var body: some View {
        VStack {
            Button(viewModel.canvasVisible.label) {
                viewModel.showOrHide()
            }
            Divider()
            if #available(macOS 14.0, *) {
                SettingsLink {
                    Text("settings")
                }.preActionButtonStyle {
                    viewModel.activateApp()
                }
            } else {
                Button("settings") {
                    viewModel.openSettings()
                }
            }
            Divider()
            Button("aboutApp") {
                viewModel.openAbout()
            }
            Button("reportAnIssue") {
                viewModel.sendIssueReport()
            }
            Button("terminateApp") {
                viewModel.terminateApp()
            }
        }
    }
}

#Preview {
    MenuView(viewModel: PreviewMock.MenuViewModelMock())
}
