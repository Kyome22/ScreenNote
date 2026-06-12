import CoreGraphics
import DataSource
import Observation

@MainActor @Observable
public final class CanvasSettings: Composable {
    private let userDefaultsRepository: UserDefaultsRepository
    private let logService: LogService

    public var clearAllObjects: Bool
    public var showColorPopover = false
    public var defaultObjectType: ObjectType
    public var defaultColorIndex: Int
    public var defaultOpacity: CGFloat
    public var defaultLineWidth: CGFloat
    public var backgroundColorIndex: Int
    public var backgroundOpacity: CGFloat
    public let action: (Action) async -> Void

    public init(
        _ appDependencies: AppDependencies,
        action: @escaping (Action) async -> Void = { _ in }
    ) {
        self.userDefaultsRepository = .init(
            appDependencies.userDefaultsClient,
            appDependencies.appStateClient
        )
        self.logService = .init(appDependencies)
        self.clearAllObjects = userDefaultsRepository.clearAllObjects
        self.defaultObjectType = userDefaultsRepository.defaultObjectType
        self.defaultColorIndex = userDefaultsRepository.defaultColorIndex
        self.defaultOpacity = userDefaultsRepository.defaultOpacity
        self.defaultLineWidth = userDefaultsRepository.defaultLineWidth
        self.backgroundColorIndex = userDefaultsRepository.backgroundColorIndex
        self.backgroundOpacity = userDefaultsRepository.backgroundOpacity
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

        case let .defaultColorSelected(index):
            defaultColorIndex = index
            userDefaultsRepository.defaultColorIndex = index

        case let .defaultOpacityChanged(opacity):
            defaultOpacity = opacity

        case .defaultOpacityCommitted:
            userDefaultsRepository.defaultOpacity = defaultOpacity

        case let .defaultLineWidthChanged(lineWidth):
            defaultLineWidth = lineWidth

        case .defaultLineWidthCommitted:
            userDefaultsRepository.defaultLineWidth = defaultLineWidth

        case let .backgroundColorSelected(index):
            backgroundColorIndex = index
            userDefaultsRepository.backgroundColorIndex = index

        case let .backgroundOpacityChanged(opacity):
            backgroundOpacity = opacity

        case .backgroundOpacityCommitted:
            userDefaultsRepository.backgroundOpacity = backgroundOpacity

        case let .colorPopoverPresented(isPresented):
            showColorPopover = isPresented
        }
    }

    public enum Action: Sendable {
        case task(String)
        case clearAllObjectsToggleSwitched(Bool)
        case defaultObjectTypePickerSelected(ObjectType)
        case defaultColorSelected(Int)
        case defaultOpacityChanged(CGFloat)
        case defaultOpacityCommitted
        case defaultLineWidthChanged(CGFloat)
        case defaultLineWidthCommitted
        case backgroundColorSelected(Int)
        case backgroundOpacityChanged(CGFloat)
        case backgroundOpacityCommitted
        case colorPopoverPresented(Bool)
    }
}
