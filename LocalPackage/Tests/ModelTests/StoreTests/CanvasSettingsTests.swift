import AllocatedUnfairLock
import CoreGraphics
import Testing

@testable import DataSource
@testable import Model

struct CanvasSettingsTests {
    @MainActor @Test
    func send_clearAllObjectsToggleSwitched_persists() async {
        let clearAllObjects = AllocatedUnfairLock<Bool?>(initialState: nil)
        let sut = CanvasSettings(.testDependencies(
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.set = { value, key in
                    let rawValue = value as? Bool
                    if key == .clearAllObjects { clearAllObjects.withLock { $0 = rawValue } }
                }
            }
        ))
        await sut.send(.clearAllObjectsToggleSwitched(true))
        #expect(sut.clearAllObjects == true)
        #expect(clearAllObjects.withLock(\.self) == true)
    }

    @MainActor @Test
    func send_defaultObjectTypePickerSelected_persists() async {
        let defaultObjectType = AllocatedUnfairLock<Int?>(initialState: nil)
        let sut = CanvasSettings(.testDependencies(
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.set = { value, key in
                    let rawValue = value as? Int
                    if key == .defaultObjectType { defaultObjectType.withLock { $0 = rawValue } }
                }
            }
        ))
        await sut.send(.defaultObjectTypePickerSelected(.lineOval))
        #expect(sut.defaultObjectType == .lineOval)
        #expect(defaultObjectType.withLock(\.self) == ObjectType.lineOval.rawValue)
    }

    @MainActor @Test
    func send_defaultColorButtonTapped_presents_popover() async {
        let sut = CanvasSettings(.testDependencies())
        await sut.send(.defaultColorButtonTapped)
        #expect(sut.showingColorPopover == true)
    }

    @MainActor @Test
    func send_defaultColorSelected_persists() async {
        let defaultColorIndex = AllocatedUnfairLock<Int?>(initialState: nil)
        let sut = CanvasSettings(.testDependencies(
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.set = { value, key in
                    let rawValue = value as? Int
                    if key == .defaultColorIndex { defaultColorIndex.withLock { $0 = rawValue } }
                }
            }
        ))
        await sut.send(.defaultColorSelected(13))
        #expect(sut.defaultColorIndex == 13)
        #expect(defaultColorIndex.withLock(\.self) == 13)
    }

    @MainActor @Test
    func send_backgroundColorSelected_persists() async {
        let backgroundColorIndex = AllocatedUnfairLock<Int?>(initialState: nil)
        let sut = CanvasSettings(.testDependencies(
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.set = { value, key in
                    let rawValue = value as? Int
                    if key == .backgroundColorIndex { backgroundColorIndex.withLock { $0 = rawValue } }
                }
            }
        ))
        await sut.send(.backgroundColorSelected(1))
        #expect(sut.backgroundColorIndex == 1)
        #expect(backgroundColorIndex.withLock(\.self) == 1)
    }

    @MainActor @Test(arguments: [
        (SliderField.defaultOpacity, CGFloat(0.4)),
        (SliderField.defaultLineWidth, CGFloat(8.0)),
        (SliderField.backgroundOpacity, CGFloat(0.5)),
    ])
    func send_sliderChanged_persists_value_only_after_editing_stops(
        _ field: SliderField,
        _ value: CGFloat
    ) async {
        let stored = AllocatedUnfairLock<Double?>(initialState: nil)
        let sut = CanvasSettings(.testDependencies(
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.set = { rawValue, key in
                    let doubleValue = (rawValue as? Double) ?? (rawValue as? CGFloat).map(Double.init)
                    if key == field.key { stored.withLock { $0 = doubleValue } }
                }
            }
        ))
        field.setValue(value, on: sut)
        await sut.send(field.changed(editing: true))
        #expect(stored.withLock(\.self) == nil)
        await sut.send(field.changed(editing: false))
        #expect(stored.withLock(\.self) == Double(value))
    }
}

enum SliderField: Sendable {
    case defaultOpacity
    case defaultLineWidth
    case backgroundOpacity

    var key: String {
        switch self {
        case .defaultOpacity: .defaultOpacity
        case .defaultLineWidth: .defaultLineWidth
        case .backgroundOpacity: .backgroundOpacity
        }
    }

    @MainActor
    func setValue(_ value: CGFloat, on store: CanvasSettings) {
        switch self {
        case .defaultOpacity: store.defaultOpacity = value
        case .defaultLineWidth: store.defaultLineWidth = value
        case .backgroundOpacity: store.backgroundOpacity = value
        }
    }

    func changed(editing: Bool) -> CanvasSettings.Action {
        switch self {
        case .defaultOpacity: .defaultOpacityChanged(editing)
        case .defaultLineWidth: .defaultLineWidthChanged(editing)
        case .backgroundOpacity: .backgroundOpacityChanged(editing)
        }
    }
}
