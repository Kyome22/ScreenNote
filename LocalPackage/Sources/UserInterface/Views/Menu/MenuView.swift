import DataSource
import Model
import SwiftUI

struct MenuView: View {
    @StateObject var store: Model.Menu

    var body: some View {
        VStack {
            Button {
                Task { await store.send(.showOrHideCanvasButtonTapped) }
            } label: {
                Text(store.canvasVisible.label, bundle: .module)
            }
            Divider()
            SettingsLink {
                Text("settings", bundle: .module)
            }
            .preActionButtonStyle {
                Task { await store.send(.settingsLinkPreActionTriggered) }
            }
            Divider()
            Button {
                Task { await store.send(.aboutButtonTapped) }
            } label: {
                Text("aboutApp", bundle: .module)
            }
            Button {
                Task { await store.send(.reportIssueButtonTapped(subject: issueSubject, body: issueBody)) }
            } label: {
                Text("reportAnIssue", bundle: .module)
            }
            Button {
                Task { await store.send(.quitButtonTapped) }
            } label: {
                Text("terminateApp", bundle: .module)
            }
        }
        .task {
            await store.send(.task(String(describing: Self.self)))
        }
        .onDisappear {
            Task { await store.send(.onDisappear) }
        }
    }

    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    private var systemVersion: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }

    private var issueSubject: String {
        "\(appName) \(String(localized: "issueReport", bundle: .module))"
    }

    private var issueBody: [String] {
        [
            String(localized: "environment\(appName)\(appVersion)\(systemVersion)", bundle: .module),
            String(localized: "whatYouTried", bundle: .module),
            String(localized: "shortDescription", bundle: .module),
            String(localized: "reproduceIssue", bundle: .module),
            String(localized: "expectedResult", bundle: .module),
        ]
    }
}

extension Model.Menu: ObservableObject {}
