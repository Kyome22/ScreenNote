import AllocatedUnfairLock
import Foundation
import Testing

@testable import DataSource
@testable import Model

struct MenuTests {
    @MainActor @Test
    func send_showOrHideCanvasButtonTapped_sends_shortcut_command() async {
        let appStateLock = AllocatedUnfairLock<AppState>(initialState: .init())
        let store = Menu(.testDependencies(appStateClient: .testDependency(appStateLock)))
        let stream = appStateLock.withLock(\.shortcutCommand.stream)
        await store.send(.showOrHideCanvasButtonTapped)
        var received = false
        for await _ in stream {
            received = true
            break
        }
        #expect(received)
    }

    @MainActor @Test
    func send_task_reflects_latest_canvas_visible_and_observes_stream() async {
        let appStateLock = AllocatedUnfairLock<AppState>(initialState: .init())
        appStateLock.withLock { $0.canvasVisibility.send(.show) }
        let store = Menu(.testDependencies(appStateClient: .testDependency(appStateLock)))
        await store.send(.task("MenuView"))
        #expect(store.canvasVisibility == .show)
        appStateLock.withLock { $0.canvasVisibility.send(.hide) }
        #expect(await waitUntil { store.canvasVisibility == .hide })
        await store.send(.onDisappear)
    }

    @MainActor @Test
    func send_settingsLinkPreActionTriggered_activates_app() async {
        let events = AllocatedUnfairLock<[String]>(initialState: [])
        let store = Menu(.testDependencies(
            nsAppClient: testDependency(of: NSAppClient.self) {
                $0.activate = { events.withLock { $0.append("activate") } }
            }
        ))
        await store.send(.settingsLinkPreActionTriggered)
        #expect(events.withLock(\.self) == ["activate"])
    }

    @MainActor @Test
    func send_aboutButtonTapped_orders_front_about_panel() async {
        let events = AllocatedUnfairLock<[String]>(initialState: [])
        let store = Menu(.testDependencies(
            nsAppClient: testDependency(of: NSAppClient.self) {
                $0.orderFrontAboutPanel = { events.withLock { $0.append("about") } }
            }
        ))
        await store.send(.aboutButtonTapped)
        #expect(events.withLock(\.self) == ["about"])
    }

    @MainActor @Test
    func send_reportIssueButtonTapped_composes_mail() async {
        let composed = AllocatedUnfairLock<[String]>(initialState: [])
        let store = Menu(.testDependencies(
            mailClient: testDependency(of: MailClient.self) {
                $0.compose = { recipients, subject, body in
                    composed.withLock { $0.append("\(recipients.joined())|\(subject)|\(body.count)") }
                }
            }
        ))
        await store.send(.reportIssueButtonTapped(subject: "Report", body: ["a", "b"]))
        #expect(composed.withLock(\.self) == ["kyomesuke@icloud.com|Report|2"])
    }

    @MainActor @Test
    func send_quitButtonTapped_terminates() async {
        let events = AllocatedUnfairLock<[String]>(initialState: [])
        let store = Menu(.testDependencies(
            nsAppClient: testDependency(of: NSAppClient.self) {
                $0.terminate = { events.withLock { $0.append("terminate") } }
            }
        ))
        await store.send(.quitButtonTapped)
        #expect(events.withLock(\.self) == ["terminate"])
    }
}
