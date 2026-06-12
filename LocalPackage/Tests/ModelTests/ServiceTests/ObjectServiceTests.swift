import AllocatedUnfairLock
import CoreGraphics
import Testing

@testable import DataSource
@testable import Model

struct ObjectServiceTests {
    private func makeService(
        canvasState: CanvasState = CanvasState()
    ) -> (ObjectService, AllocatedUnfairLock<AppState>) {
        let appStateLock = AllocatedUnfairLock<AppState>(initialState: .init())
        appStateLock.withLock { $0.canvasState.send(canvasState) }
        let service = ObjectService(.testDependencies(
            appStateClient: .testDependency(appStateLock),
            userDefaultsClient: TestUserDefaults().client()
        ))
        return (service, appStateLock)
    }

    private func canvasState(_ appStateLock: AllocatedUnfairLock<AppState>) -> CanvasState {
        appStateLock.withLock(\.canvasState.latestValue) ?? CanvasState()
    }

    private func rect(_ originX: CGFloat, _ originY: CGFloat, _ size: CGFloat, isSelected: Bool = false) -> Object {
        Object(
            .fillRect,
            0,
            1.0,
            4.0,
            [CGPoint(x: originX, y: originY), CGPoint(x: originX + size, y: originY + size)],
            isSelected: isSelected
        )
    }

    @Test func dragBegan_pen_appends_object_and_pushes_history() {
        let (service, appStateLock) = makeService()
        service.dragBegan(location: CGPoint(x: 10, y: 10))
        let state = canvasState(appStateLock)
        #expect(state.objects.count == 1)
        #expect(state.objects[0].type == .pen)
        #expect(state.objects[0].points == [CGPoint(x: 10, y: 10)])
        #expect(appStateLock.withLock(\.undoStack) == [[]])
    }

    @Test func dragMoved_pen_appends_points() {
        let (service, appStateLock) = makeService()
        service.dragBegan(location: CGPoint(x: 10, y: 10))
        service.dragMoved(startLocation: CGPoint(x: 10, y: 10), location: CGPoint(x: 20, y: 20))
        let state = canvasState(appStateLock)
        #expect(state.objects[0].points == [CGPoint(x: 10, y: 10), CGPoint(x: 20, y: 20)])
    }

    @Test func dragBegan_shape_appends_two_point_object() {
        var initialState = CanvasState()
        initialState.objectType = .fillRect
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.dragBegan(location: CGPoint(x: 10, y: 10))
        let state = canvasState(appStateLock)
        #expect(state.objects[0].points == [CGPoint(x: 10, y: 10), CGPoint(x: 10, y: 10)])
    }

    @Test func dragMoved_shape_updates_endpoint() {
        var initialState = CanvasState()
        initialState.objectType = .lineOval
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.dragBegan(location: CGPoint(x: 10, y: 10))
        service.dragMoved(startLocation: CGPoint(x: 10, y: 10), location: CGPoint(x: 60, y: 40))
        let state = canvasState(appStateLock)
        #expect(state.objects[0].points == [CGPoint(x: 10, y: 10), CGPoint(x: 60, y: 40)])
    }

    @Test func dragEnded_shape_tiny_drag_reverts() {
        var initialState = CanvasState()
        initialState.objectType = .line
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.dragBegan(location: CGPoint(x: 10, y: 10))
        service.dragMoved(startLocation: CGPoint(x: 10, y: 10), location: CGPoint(x: 12, y: 12))
        service.dragEnded(startLocation: CGPoint(x: 10, y: 10), location: CGPoint(x: 12, y: 12))
        #expect(canvasState(appStateLock).objects.isEmpty)
    }

    @Test func dragEnded_shape_long_drag_keeps_object() {
        var initialState = CanvasState()
        initialState.objectType = .line
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.dragBegan(location: CGPoint(x: 10, y: 10))
        service.dragMoved(startLocation: CGPoint(x: 10, y: 10), location: CGPoint(x: 100, y: 100))
        service.dragEnded(startLocation: CGPoint(x: 10, y: 10), location: CGPoint(x: 100, y: 100))
        #expect(canvasState(appStateLock).objects.count == 1)
    }

    @Test func dragBegan_select_on_empty_space_starts_selection_rectangle() {
        var initialState = CanvasState()
        initialState.objectType = .select
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.dragBegan(location: CGPoint(x: 50, y: 50))
        let state = canvasState(appStateLock)
        #expect(state.rectangleForSelection != nil)
        #expect(appStateLock.withLock(\.dragContext.selectType) == .rectangle)
    }

    @Test func dragEnded_select_rectangle_selects_contained_objects() {
        var initialState = CanvasState()
        initialState.objectType = .select
        initialState.objects = [rect(10, 10, 20), rect(200, 200, 20)]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.dragBegan(location: CGPoint(x: 0, y: 0))
        service.dragMoved(startLocation: CGPoint(x: 0, y: 0), location: CGPoint(x: 100, y: 100))
        service.dragEnded(startLocation: CGPoint(x: 0, y: 0), location: CGPoint(x: 100, y: 100))
        let state = canvasState(appStateLock)
        #expect(state.objects[0].isSelected == true)
        #expect(state.objects[1].isSelected == false)
        #expect(state.rectangleForSelection == nil)
    }

    @Test func dragBegan_select_on_object_selects_and_drag_moves_it() {
        var initialState = CanvasState()
        initialState.objectType = .select
        initialState.objects = [rect(10, 10, 20)]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.dragBegan(location: CGPoint(x: 20, y: 20))
        #expect(appStateLock.withLock(\.dragContext.action) == .move)
        service.dragMoved(startLocation: CGPoint(x: 20, y: 20), location: CGPoint(x: 30, y: 25))
        service.dragEnded(startLocation: CGPoint(x: 20, y: 20), location: CGPoint(x: 30, y: 25))
        let state = canvasState(appStateLock)
        #expect(state.objects[0].bounds == CGRect(x: 20, y: 15, width: 20, height: 20))
        #expect(state.objects[0].isSelected == true)
    }

    @Test func dragBegan_select_on_anchor_resizes_selection() {
        var initialState = CanvasState()
        initialState.objectType = .select
        initialState.objects = [rect(10, 10, 20, isSelected: true)]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.dragBegan(location: CGPoint(x: 30, y: 30))
        #expect(appStateLock.withLock(\.dragContext.action) == .resize)
        #expect(appStateLock.withLock(\.dragContext.anchor) == .bottomRight)
        service.dragMoved(startLocation: CGPoint(x: 30, y: 30), location: CGPoint(x: 50, y: 50))
        service.dragEnded(startLocation: CGPoint(x: 30, y: 30), location: CGPoint(x: 50, y: 50))
        let state = canvasState(appStateLock)
        #expect(state.objects[0].bounds == CGRect(x: 10, y: 10, width: 40, height: 40))
    }

    @Test func dragEnded_select_without_move_reverts_history() {
        var initialState = CanvasState()
        initialState.objectType = .select
        initialState.objects = [rect(10, 10, 20)]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.dragBegan(location: CGPoint(x: 20, y: 20))
        service.dragEnded(startLocation: CGPoint(x: 20, y: 20), location: CGPoint(x: 20, y: 20))
        let state = canvasState(appStateLock)
        #expect(state.objects[0].isSelected == true)
        #expect(appStateLock.withLock(\.undoStack).isEmpty)
    }

    @Test func dragBegan_text_creates_empty_input_properties() {
        var initialState = CanvasState()
        initialState.objectType = .text
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.dragBegan(location: CGPoint(x: 100, y: 100))
        let state = canvasState(appStateLock)
        #expect(state.inputTextProperties?.inputText == "")
        #expect(state.inputTextProperties?.fontSize == 40.0)
        #expect(state.inputTextProperties?.object.points == [CGPoint(x: 100, y: 100)])
    }

    @Test func dragBegan_text_on_existing_text_starts_editing_and_hides_it() {
        var initialState = CanvasState()
        initialState.objectType = .text
        let textObject = Object(0, 1.0, [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 40)], "hello", .up)
        initialState.objects = [textObject]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.dragBegan(location: CGPoint(x: 50, y: 20))
        let state = canvasState(appStateLock)
        #expect(state.inputTextProperties?.inputText == "hello")
        #expect(state.objects[0].isHidden == true)
    }

    @Test func endEditing_new_text_appends_text_object() {
        var initialState = CanvasState()
        initialState.objectType = .text
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.dragBegan(location: CGPoint(x: 100, y: 100))
        var properties = canvasState(appStateLock).inputTextProperties!
        properties.inputText = "note"
        service.endEditing(properties)
        let state = canvasState(appStateLock)
        #expect(state.objects.count == 1)
        #expect(state.objects[0].text == "note")
        #expect(state.inputTextProperties == nil)
    }

    @Test func endEditing_empty_text_removes_edited_object() {
        var initialState = CanvasState()
        initialState.objectType = .text
        let textObject = Object(0, 1.0, [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 40)], "hello", .up)
        initialState.objects = [textObject]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.dragBegan(location: CGPoint(x: 50, y: 20))
        var properties = canvasState(appStateLock).inputTextProperties!
        properties.inputText = ""
        service.endEditing(properties)
        let state = canvasState(appStateLock)
        #expect(state.objects.isEmpty)
    }

    @Test func endEditing_changed_text_updates_object() {
        var initialState = CanvasState()
        initialState.objectType = .text
        let textObject = Object(0, 1.0, [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 40)], "hello", .up)
        initialState.objects = [textObject]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.dragBegan(location: CGPoint(x: 50, y: 20))
        var properties = canvasState(appStateLock).inputTextProperties!
        properties.inputText = "world"
        service.endEditing(properties)
        let state = canvasState(appStateLock)
        #expect(state.objects.count == 1)
        #expect(state.objects[0].text == "world")
        #expect(state.objects[0].isHidden == false)
    }

    @Test func updateObjectType_to_drawing_tool_unselects_objects() {
        var initialState = CanvasState()
        initialState.objectType = .select
        initialState.objects = [rect(10, 10, 20, isSelected: true)]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.updateObjectType(.pen)
        let state = canvasState(appStateLock)
        #expect(state.objectType == .pen)
        #expect(state.objects[0].isSelected == false)
    }

    @Test func updateColor_updates_properties_and_selected_objects_with_history() {
        var initialState = CanvasState()
        initialState.objectType = .select
        initialState.objects = [rect(10, 10, 20, isSelected: true), rect(50, 50, 20)]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.updateColor(7)
        let state = canvasState(appStateLock)
        #expect(state.objectProperties.paletteIndex == 7)
        #expect(state.objects[0].paletteIndex == 7)
        #expect(state.objects[1].paletteIndex == 0)
        #expect(appStateLock.withLock(\.undoStack.count) == 1)
    }

    @Test func updateOpacity_and_lineWidth_apply_to_selected_objects() {
        var initialState = CanvasState()
        initialState.objectType = .select
        initialState.objects = [rect(10, 10, 20, isSelected: true)]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.startUpdatingOpacity()
        service.updateOpacity(0.5)
        service.startUpdatingLineWidth()
        service.updateLineWidth(10.0)
        let state = canvasState(appStateLock)
        #expect(state.objectProperties.opacity == 0.5)
        #expect(state.objectProperties.lineWidth == 10.0)
        #expect(state.objects[0].opacity == 0.5)
        #expect(state.objects[0].lineWidth == 10.0)
        #expect(appStateLock.withLock(\.undoStack.count) == 2)
    }

    @Test func arrange_bringToFrontmost_moves_selected_to_end() {
        var initialState = CanvasState()
        initialState.objectType = .select
        let selected = rect(10, 10, 20, isSelected: true)
        let other = rect(50, 50, 20)
        initialState.objects = [selected, other]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.arrange(.bringToFrontmost)
        let state = canvasState(appStateLock)
        #expect(state.objects.map(\.id) == [other.id, selected.id])
    }

    @Test func align_horizontalAlignLeft_aligns_selected_objects() {
        var initialState = CanvasState()
        initialState.objectType = .select
        initialState.objects = [rect(10, 10, 20, isSelected: true), rect(50, 50, 20, isSelected: true)]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.align(.horizontalAlignLeft)
        let state = canvasState(appStateLock)
        #expect(state.objects[0].bounds.minX == 10)
        #expect(state.objects[1].bounds.minX == 10)
        #expect(state.objects[1].bounds.minY == 50)
    }

    @Test func flip_flipHorizontal_mirrors_points_around_selection_center() {
        var initialState = CanvasState()
        initialState.objectType = .select
        initialState.objects = [
            rect(0, 0, 10, isSelected: true),
            rect(30, 0, 10, isSelected: true),
        ]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.flip(.flipHorizontal)
        let state = canvasState(appStateLock)
        #expect(state.objects[0].bounds == CGRect(x: 30, y: 0, width: 10, height: 10))
        #expect(state.objects[1].bounds == CGRect(x: 0, y: 0, width: 10, height: 10))
    }

    @Test func rotate_rotateRight_rotates_points_around_selection_center() {
        var initialState = CanvasState()
        initialState.objectType = .select
        initialState.objects = [rect(0, 0, 20, isSelected: true)]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.rotate(.rotateRight)
        let state = canvasState(appStateLock)
        #expect(abs(state.objects[0].bounds.minX - 0) < 0.0001)
        #expect(abs(state.objects[0].bounds.minY - 0) < 0.0001)
        #expect(abs(state.objects[0].bounds.width - 20) < 0.0001)
    }

    @Test func rotate_rotates_text_orientation() {
        var initialState = CanvasState()
        initialState.objectType = .select
        var textObject = Object(0, 1.0, [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 40)], "hello", .up)
        textObject.isSelected = true
        initialState.objects = [textObject]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.rotate(.rotateRight)
        #expect(canvasState(appStateLock).objects[0].textOrientation == .right)
    }

    @Test func duplicateSelectedObjects_appends_offset_copies() {
        var initialState = CanvasState()
        initialState.objectType = .select
        initialState.objects = [rect(10, 10, 20, isSelected: true)]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.duplicateSelectedObjects()
        let state = canvasState(appStateLock)
        #expect(state.objects.count == 2)
        #expect(state.objects[0].isSelected == false)
        #expect(state.objects[1].isSelected == true)
        #expect(state.objects[1].bounds == CGRect(x: 30, y: 30, width: 20, height: 20))
    }

    @Test func delete_removes_selected_objects() {
        var initialState = CanvasState()
        initialState.objectType = .select
        initialState.objects = [rect(10, 10, 20, isSelected: true), rect(50, 50, 20)]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.delete()
        let state = canvasState(appStateLock)
        #expect(state.objects.count == 1)
        #expect(state.objects[0].bounds.minX == 50)
    }

    @Test func selectAll_selects_all_objects_only_in_select_mode() {
        var initialState = CanvasState()
        initialState.objects = [rect(10, 10, 20), rect(50, 50, 20)]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.selectAll()
        #expect(canvasState(appStateLock).objects.allSatisfy { !$0.isSelected })
        service.updateObjectType(.select)
        service.selectAll()
        #expect(canvasState(appStateLock).objects.allSatisfy { $0.isSelected })
    }

    @Test func clear_removes_all_objects_with_history() {
        var initialState = CanvasState()
        initialState.objects = [rect(10, 10, 20)]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.clear()
        #expect(canvasState(appStateLock).objects.isEmpty)
        service.undo()
        #expect(canvasState(appStateLock).objects.count == 1)
    }

    @Test func clear_is_ignored_while_inputting_text() {
        var initialState = CanvasState()
        initialState.objects = [rect(10, 10, 20)]
        initialState.inputTextProperties = InputTextProperties(
            object: Object(0, 1.0, [CGPoint(x: 0, y: 0)], "", .up),
            inputText: "",
            fontSize: 40.0
        )
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.clear()
        #expect(canvasState(appStateLock).objects.count == 1)
    }

    @Test func undo_redo_round_trip() {
        let (service, appStateLock) = makeService()
        service.dragBegan(location: CGPoint(x: 10, y: 10))
        service.dragMoved(startLocation: CGPoint(x: 10, y: 10), location: CGPoint(x: 50, y: 50))
        #expect(canvasState(appStateLock).objects.count == 1)
        service.undo()
        #expect(canvasState(appStateLock).objects.isEmpty)
        service.redo()
        #expect(canvasState(appStateLock).objects.count == 1)
    }

    @Test func undo_is_ignored_while_inputting_text() {
        var initialState = CanvasState()
        initialState.objects = [rect(10, 10, 20)]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.clear()
        appStateLock.withLock { appState in
            var state = appState.canvasState.latestValue!
            state.inputTextProperties = InputTextProperties(
                object: Object(0, 1.0, [CGPoint(x: 0, y: 0)], "", .up),
                inputText: "",
                fontSize: 40.0
            )
            appState.canvasState.send(state)
        }
        service.undo()
        #expect(canvasState(appStateLock).objects.isEmpty)
    }

    @Test func undo_caps_history_at_15_levels() {
        let (service, appStateLock) = makeService()
        for index in 0 ..< 20 {
            service.dragBegan(location: CGPoint(x: CGFloat(index), y: 0))
        }
        #expect(appStateLock.withLock(\.undoStack.count) == 15)
    }

    @Test func new_action_clears_redo_stack() {
        let (service, appStateLock) = makeService()
        service.dragBegan(location: CGPoint(x: 10, y: 10))
        service.undo()
        #expect(appStateLock.withLock(\.redoStack.count) == 1)
        service.dragBegan(location: CGPoint(x: 20, y: 20))
        #expect(appStateLock.withLock(\.redoStack).isEmpty)
    }

    @Test func resetHistory_clears_objects_properties_and_stacks() {
        var initialState = CanvasState()
        initialState.objectType = .select
        initialState.objects = [rect(10, 10, 20)]
        let (service, appStateLock) = makeService(canvasState: initialState)
        service.clear()
        service.resetHistory()
        let state = canvasState(appStateLock)
        #expect(state.objects.isEmpty)
        #expect(state.objectType == .pen)
        #expect(appStateLock.withLock(\.undoStack).isEmpty)
        #expect(appStateLock.withLock(\.redoStack).isEmpty)
    }

    @Test func resetDefaultSettings_applies_repository_defaults() {
        let appStateLock = AllocatedUnfairLock<AppState>(initialState: .init())
        appStateLock.withLock { $0.canvasState.send(CanvasState()) }
        let userDefaults = TestUserDefaults()
        let appDependencies = AppDependencies.testDependencies(
            appStateClient: .testDependency(appStateLock),
            userDefaultsClient: userDefaults.client()
        )
        let repository = UserDefaultsRepository(userDefaults.client(), .testDependency(appStateLock))
        repository.defaultObjectType = .arrow
        repository.defaultColorIndex = 9
        repository.defaultOpacity = 0.4
        repository.defaultLineWidth = 12.0
        let service = ObjectService(appDependencies)
        service.resetDefaultSettings()
        let state = appStateLock.withLock(\.canvasState.latestValue)!
        #expect(state.objectType == .arrow)
        #expect(state.objectProperties == ObjectProperties(paletteIndex: 9, opacity: 0.4, lineWidth: 12.0))
    }
}
