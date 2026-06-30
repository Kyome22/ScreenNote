import DataSource
import Model
import SwiftUI

struct SettingsView: View {
    @Environment(\.appDependencies) private var appDependencies
    @State private var settingsTab = SettingsTabType.general

    var body: some View {
        TabView(selection: $settingsTab) {
            GeneralSettingsView(store: .init(appDependencies))
                .tabItem {
                    Label {
                        Text("general", bundle: .module)
                    } icon: {
                        Image(systemName: "gear")
                    }
                }
                .tag(SettingsTabType.general)
            CanvasSettingsView(store: .init(appDependencies))
                .tabItem {
                    Label {
                        Text("canvas", bundle: .module)
                    } icon: {
                        Image(systemName: "square.and.pencil")
                    }
                }
                .tag(SettingsTabType.canvas)
            DonationSettingsView(store: .init(appDependencies))
                .tabItem {
                    Label {
                        Text("donationTab", bundle: .module)
                    } icon: {
                        Image(systemName: "mug")
                    }
                }
                .tag(SettingsTabType.donation)
        }
        .fixedSize()
        .accessibilityIdentifier("Settings")
    }
}
