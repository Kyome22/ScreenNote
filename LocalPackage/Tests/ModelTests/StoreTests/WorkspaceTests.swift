import AllocatedUnfairLock
import CoreGraphics
import Testing

@testable import DataSource
@testable import Model

struct WorkspaceTests {
    @MainActor private func makeStore() -> (Workspace, AllocatedUnfairLock<AppState>) {
        let appStateLock = AllocatedUnfairLock<AppState>(initialState: .init())
        appStateLock.withLock { $0.canvasState.send(CanvasState()) }
        let store = Workspace(.testDependencies(
            appStateClient: .testDependency(appStateLock)
        ))
        return (store, appStateLock)
    }

    @MainActor @Test
    func init_falls_back_to_repository_toolBarPosition() {
        let (store, _) = makeStore()
        #expect(store.toolBarPosition == .top)
    }

    @MainActor @Test
    func send_task_observes_canvas_state_stream() async {
        let (store, appStateLock) = makeStore()
        await store.send(.task("WorkspaceView"))
        appStateLock.withLock { appState in
            var state = appState.canvasState.latestValue!
            state.objectType = .arrow
            appState.canvasState.send(state)
        }
        #expect(await waitUntil { store.canvasState.objectType == .arrow })
        await store.send(.onDisappear)
    }

    @MainActor @Test
    func send_drag_actions_draw_an_object() async {
        let (store, appStateLock) = makeStore()
        await store.send(.dragBegan(CGPoint(x: 10, y: 10)))
        await store.send(.dragMoved(CGPoint(x: 10, y: 10), CGPoint(x: 50, y: 50)))
        await store.send(.dragEnded(CGPoint(x: 10, y: 10), CGPoint(x: 50, y: 50)))
        #expect(appStateLock.withLock(\.canvasState.latestValue)?.objects.count == 1)
    }

    @MainActor @Test
    func send_objectTypeSelected_updates_canvas_state() async {
        let (store, appStateLock) = makeStore()
        await store.send(.objectTypeSelected(.fillOval))
        #expect(appStateLock.withLock(\.canvasState.latestValue)?.objectType == .fillOval)
    }

    @MainActor @Test
    func send_inputTextSubmitted_ends_editing_with_typed_text() async {
        let (store, appStateLock) = makeStore()
        await store.send(.task("WorkspaceView"))
        await store.send(.objectTypeSelected(.text))
        await store.send(.dragBegan(CGPoint(x: 100, y: 100)))
        await store.send(.dragEnded(CGPoint(x: 100, y: 100), CGPoint(x: 100, y: 100)))
        #expect(await waitUntil { store.canvasState.inputTextProperties != nil })
        await store.send(.inputTextChanged("memo"))
        await store.send(.inputTextSubmitted)
        let state = appStateLock.withLock(\.canvasState.latestValue)
        #expect(state?.objects.first?.text == "memo")
        #expect(state?.inputTextProperties == nil)
        await store.send(.onDisappear)
    }

    @MainActor @Test
    func stream_sync_prefills_inputText_when_editing_existing_text() async {
        let (store, appStateLock) = makeStore()
        await store.send(.task("WorkspaceView"))
        appStateLock.withLock { appState in
            var state = appState.canvasState.latestValue!
            state.inputTextProperties = InputTextProperties(
                object: Object(0, 1.0, [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 40)], "hello", .up),
                inputText: "hello",
                fontSize: 40.0
            )
            appState.canvasState.send(state)
        }
        #expect(await waitUntil { store.inputText == "hello" })
        await store.send(.onDisappear)
    }

    @MainActor @Test(arguments: PopoverButton.allCases)
    func send_buttonTapped_presents_corresponding_popover(_ button: PopoverButton) async {
        let (store, _) = makeStore()
        #expect(button.isPresented(in: store) == false)
        await store.send(button.action)
        #expect(button.isPresented(in: store) == true)
    }

    @MainActor @Test
    func disabled_flags_derive_from_canvas_state() async {
        let (store, appStateLock) = makeStore()
        await store.send(.task("WorkspaceView"))
        #expect(store.disabledWhileInputtingText == false)
        #expect(store.disabledEditObject == true)
        appStateLock.withLock { appState in
            var state = appState.canvasState.latestValue!
            state.objectType = .select
            state.objects = [Object(
                .fillRect,
                0,
                1.0,
                4.0,
                [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 10)],
                isSelected: true
            )]
            appState.canvasState.send(state)
        }
        #expect(await waitUntil { store.disabledEditObject == false })
        await store.send(.onDisappear)
    }

    @MainActor @Test
    func send_undo_redo_buttons_travel_history() async {
        let (store, appStateLock) = makeStore()
        await store.send(.dragBegan(CGPoint(x: 10, y: 10)))
        await store.send(.dragEnded(CGPoint(x: 10, y: 10), CGPoint(x: 60, y: 60)))
        await store.send(.undoButtonTapped)
        #expect(appStateLock.withLock(\.canvasState.latestValue)?.objects.isEmpty == true)
        await store.send(.redoButtonTapped)
        #expect(appStateLock.withLock(\.canvasState.latestValue)?.objects.count == 1)
    }
}

enum PopoverButton: CaseIterable {
    case color
    case lineWidth
    case arrange
    case align
    case flip
    case rotate

    var action: Workspace.Action {
        switch self {
        case .color: .colorButtonTapped
        case .lineWidth: .lineWidthButtonTapped
        case .arrange: .arrangeButtonTapped
        case .align: .alignButtonTapped
        case .flip: .flipButtonTapped
        case .rotate: .rotateButtonTapped
        }
    }

    @MainActor
    func isPresented(in store: Workspace) -> Bool {
        switch self {
        case .color: store.showingColorPopover
        case .lineWidth: store.showingLineWidthPopover
        case .arrange: store.showingArrangePopover
        case .align: store.showingAlignPopover
        case .flip: store.showingFlipPopover
        case .rotate: store.showingRotatePopover
        }
    }
}
