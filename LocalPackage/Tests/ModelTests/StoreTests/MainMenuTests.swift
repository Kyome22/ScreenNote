import AllocatedUnfairLock
import Foundation
import Testing

@testable import DataSource
@testable import Model

struct MainMenuTests {
    @MainActor @Test
    func send_canvasVisibilityButtonTapped_toggles_visibility() async {
        let appStateLock = AllocatedUnfairLock<AppState>(initialState: .init())
        let store = MainMenu(.testDependencies(appStateClient: .testDependency(appStateLock)))
        await store.send(.canvasVisibilityButtonTapped)
        #expect(appStateLock.withLock(\.canvasVisibility.latestValue) == .visible)
        await store.send(.task("MainMenuView"))
        await store.send(.canvasVisibilityButtonTapped)
        #expect(appStateLock.withLock(\.canvasVisibility.latestValue) == .hidden)
        await store.send(.onDisappear)
    }

    @MainActor @Test
    func send_task_reflects_latest_canvas_visibility_and_observes_stream() async {
        let appStateLock = AllocatedUnfairLock<AppState>(initialState: .init())
        appStateLock.withLock { $0.canvasVisibility.send(.visible) }
        let store = MainMenu(.testDependencies(appStateClient: .testDependency(appStateLock)))
        await store.send(.task("MainMenuView"))
        #expect(store.canvasVisibility == .visible)
        appStateLock.withLock { $0.canvasVisibility.send(.hidden) }
        #expect(await waitUntil { store.canvasVisibility == .hidden })
        await store.send(.onDisappear)
    }

    @MainActor @Test
    func send_settingsLinkPreActionTriggered_activates_app() async {
        let activated = AllocatedUnfairLock<[Bool]>(initialState: [])
        let store = MainMenu(.testDependencies(
            nsAppClient: testDependency(of: NSAppClient.self) {
                $0.activate = { isOn in activated.withLock { $0.append(isOn) } }
            }
        ))
        await store.send(.settingsLinkPreActionTriggered)
        #expect(activated.withLock(\.self) == [true])
    }

    @MainActor @Test
    func send_aboutButtonTapped_orders_front_about_panel() async {
        let aboutShown = AllocatedUnfairLock<Bool>(initialState: false)
        let store = MainMenu(.testDependencies(
            nsAppClient: testDependency(of: NSAppClient.self) {
                $0.orderFrontStandardAboutPanel = { _ in aboutShown.withLock { $0 = true } }
            }
        ))
        await store.send(.aboutButtonTapped)
        #expect(aboutShown.withLock(\.self) == true)
    }

    @MainActor @Test
    func send_reportIssueButtonTapped_opens_mailto_url() async {
        let opened = AllocatedUnfairLock<[URL]>(initialState: [])
        let store = MainMenu(.testDependencies(
            nsWorkspaceClient: testDependency(of: NSWorkspaceClient.self) {
                $0.open = { url in
                    opened.withLock { $0.append(url) }
                    return true
                }
            }
        ))
        await store.send(.reportIssueButtonTapped(.init(subject: "Report", body: "detail")))
        let url = opened.withLock(\.self).first
        #expect(url?.scheme == "mailto")
        #expect(url?.absoluteString == "mailto:kyomesuke@icloud.com?subject=Report&body=detail")
    }

    @MainActor @Test
    func send_quitButtonTapped_terminates() async {
        let terminated = AllocatedUnfairLock<Bool>(initialState: false)
        let store = MainMenu(.testDependencies(
            nsAppClient: testDependency(of: NSAppClient.self) {
                $0.terminate = { _ in terminated.withLock { $0 = true } }
            }
        ))
        await store.send(.quitButtonTapped)
        #expect(terminated.withLock(\.self) == true)
    }
}
