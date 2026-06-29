import DataSource
import Model
import SwiftUI

struct MainMenuView: View {
    @StateObject var store: MainMenu

    var body: some View {
        VStack {
            Button {
                Task {
                    await store.send(.canvasVisibilityButtonTapped)
                }
            } label: {
                Text(store.canvasVisibility.label)
            }
            Divider()
            SettingsLink {
                Text("settings", bundle: .module)
            }
            .buttonStyle(.preAction {
                await store.send(.settingsLinkPreActionTriggered)
            })
            Divider()
            Button {
                Task {
                    await store.send(.aboutButtonTapped)
                }
            } label: {
                Text("aboutApp", bundle: .module)
            }
            Button {
                Task {
                    await store.send(.reportIssueButtonTapped(.init(
                        subject: String(localized: "mailSubject\(store.environmentInfo.appName)", bundle: .module),
                        body: String(format: String(localized: "mailBody", bundle: .module), arguments: store.environmentInfo.items)
                    )))
                }
            } label: {
                Text("reportAnIssue", bundle: .module)
            }
            Button {
                Task {
                    await store.send(.quitButtonTapped)
                }
            } label: {
                Text("terminateApp", bundle: .module)
            }
        }
        .task {
            await store.send(.task(String(describing: Self.self)))
        }
        .onDisappear {
            Task {
                await store.send(.onDisappear)
            }
        }
    }
}

extension MainMenu: ObservableObject {}
