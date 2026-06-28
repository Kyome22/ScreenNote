import AllocatedUnfairLock
import Testing
import WindowSceneKit

@testable import DataSource
@testable import Model

struct PanelServiceTests {
    private func makeService(
        showsTriggerMethod: Bool = false,
        onRequest: @escaping @Sendable (String) -> Void = { _ in },
        onActivate: @escaping @MainActor @Sendable (Bool) -> Void = { _ in }
    ) -> PanelService {
        PanelService(.testDependencies(
            nsAppClient: testDependency(of: NSAppClient.self) {
                $0.activate = onActivate
            },
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.bool = { _ in showsTriggerMethod }
            },
            windowSceneMessengerClient: testDependency(of: WindowSceneMessengerClient.self) {
                $0.request = { action, key in onRequest("\(action)|\(key.id)") }
            }
        ))
    }

    @Test(arguments: [
        (true, ["open|triggerMethodPanel"]),
        (false, [String]()),
    ])
    func showTriggerMethodPanel_requests_open_only_when_enabled(
        _ showsTriggerMethod: Bool,
        _ expected: [String]
    ) {
        let requests = AllocatedUnfairLock<[String]>(initialState: [])
        let service = makeService(
            showsTriggerMethod: showsTriggerMethod,
            onRequest: { entry in requests.withLock { $0.append(entry) } }
        )
        service.showTriggerMethodPanel()
        #expect(requests.withLock(\.self) == expected)
    }

    @Test(arguments: [
        (true, ["close|triggerMethodPanel"]),
        (false, [String]()),
    ])
    func hideTriggerMethodPanel_requests_close_only_when_enabled(
        _ showsTriggerMethod: Bool,
        _ expected: [String]
    ) {
        let requests = AllocatedUnfairLock<[String]>(initialState: [])
        let service = makeService(
            showsTriggerMethod: showsTriggerMethod,
            onRequest: { entry in requests.withLock { $0.append(entry) } }
        )
        service.hideTriggerMethodPanel()
        #expect(requests.withLock(\.self) == expected)
    }

    @MainActor @Test(arguments: [
        (CanvasVisibility.visible, ["open|workspacePanel"], [true]),
        (CanvasVisibility.hidden, ["close|workspacePanel"], [Bool]()),
    ])
    func toggleWorkspacePanel_requests_panel_and_activates_only_when_visible(
        _ visibility: CanvasVisibility,
        _ expectedRequests: [String],
        _ expectedActivations: [Bool]
    ) {
        let requests = AllocatedUnfairLock<[String]>(initialState: [])
        let activations = AllocatedUnfairLock<[Bool]>(initialState: [])
        let service = makeService(
            onRequest: { entry in requests.withLock { $0.append(entry) } },
            onActivate: { isOn in activations.withLock { $0.append(isOn) } }
        )
        service.toggleWorkspacePanel(to: visibility)
        #expect(requests.withLock(\.self) == expectedRequests)
        #expect(activations.withLock(\.self) == expectedActivations)
    }
}
