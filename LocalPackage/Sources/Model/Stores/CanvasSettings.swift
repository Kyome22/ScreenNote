import CoreGraphics
import DataSource
import Observation

@MainActor @Observable
public final class CanvasSettings: Composable {
    private let userDefaultsRepository: UserDefaultsRepository
    private let logService: LogService

    public var clearAllObjects: Bool
    public var defaultObjectType: ObjectType
    public var defaultColorIndex: Int
    public var showingColorPopover: Bool
    public var defaultOpacity: CGFloat
    public var defaultLineWidth: CGFloat
    public var backgroundColorIndex: Int
    public var backgroundOpacity: CGFloat
    public let action: (Action) async -> Void

    public init(
        _ appDependencies: AppDependencies,
        clearAllObjects: Bool? = nil,
        defaultObjectType: ObjectType? = nil,
        defaultColorIndex: Int? = nil,
        showingColorPopover: Bool = false,
        defaultOpacity: CGFloat? = nil,
        defaultLineWidth: CGFloat? = nil,
        backgroundColorIndex: Int? = nil,
        backgroundOpacity: CGFloat? = nil,
        action: @escaping (Action) async -> Void = { _ in }
    ) {
        self.userDefaultsRepository = .init(appDependencies.userDefaultsClient)
        self.logService = .init(appDependencies)
        self.clearAllObjects = clearAllObjects ?? userDefaultsRepository.clearAllObjects
        self.defaultObjectType = defaultObjectType ?? userDefaultsRepository.defaultObjectType
        self.defaultColorIndex = defaultColorIndex ?? userDefaultsRepository.defaultColorIndex
        self.showingColorPopover = showingColorPopover
        self.defaultOpacity = defaultOpacity ?? userDefaultsRepository.defaultOpacity
        self.defaultLineWidth = defaultLineWidth ?? userDefaultsRepository.defaultLineWidth
        self.backgroundColorIndex = backgroundColorIndex ?? userDefaultsRepository.backgroundColorIndex
        self.backgroundOpacity = backgroundOpacity ?? userDefaultsRepository.backgroundOpacity
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))

        case let .clearAllObjectsToggleSwitched(isOn):
            clearAllObjects = isOn
            userDefaultsRepository.clearAllObjects = isOn

        case let .defaultObjectTypePickerSelected(objectType):
            defaultObjectType = objectType
            userDefaultsRepository.defaultObjectType = objectType

        case .defaultColorButtonTapped:
            showingColorPopover = true

        case let .defaultColorSelected(index):
            defaultColorIndex = index
            userDefaultsRepository.defaultColorIndex = index

        case let .defaultOpacityChanged(editing):
            guard !editing else { return }
            userDefaultsRepository.defaultOpacity = defaultOpacity

        case let .defaultLineWidthChanged(editing):
            guard !editing else { return }
            userDefaultsRepository.defaultLineWidth = defaultLineWidth

        case let .backgroundColorSelected(index):
            backgroundColorIndex = index
            userDefaultsRepository.backgroundColorIndex = index

        case let .backgroundOpacityChanged(editing):
            guard !editing else { return }
            userDefaultsRepository.backgroundOpacity = backgroundOpacity
        }
    }

    public enum Action: Sendable {
        case task(String)
        case clearAllObjectsToggleSwitched(Bool)
        case defaultObjectTypePickerSelected(ObjectType)
        case defaultColorButtonTapped
        case defaultColorSelected(Int)
        case defaultOpacityChanged(Bool)
        case defaultLineWidthChanged(Bool)
        case backgroundColorSelected(Int)
        case backgroundOpacityChanged(Bool)
    }
}
