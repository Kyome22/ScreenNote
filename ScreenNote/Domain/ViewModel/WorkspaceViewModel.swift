/*
  WorkspaceViewModel.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/01.
  
*/

import Foundation

protocol WorkspaceViewModel: ObservableObject {
    associatedtype TBM: ToolBarModel
    associatedtype CVM: CanvasViewModel

    var objectModel: ObjectModel { get }
    var toolBarPosition: ToolBarPosition { get }

    init(_ objectModel: ObjectModel,
         _ toolBarPosition: ToolBarPosition)
}

final class WorkspaceViewModelImpl: WorkspaceViewModel {
    typealias TBM = ToolBarModelImpl
    typealias CVM = CanvasViewModelImpl

    let objectModel: ObjectModel
    let toolBarPosition: ToolBarPosition

    init(
        _ objectModel: ObjectModel,
        _ toolBarPosition: ToolBarPosition
    ) {
        self.objectModel = objectModel
        self.toolBarPosition = toolBarPosition
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class WorkspaceViewModelMock: WorkspaceViewModel {
        typealias TBM = ToolBarModelMock
        typealias CVM = CanvasViewModelMock

        let objectModel: ObjectModel = ObjectModelMock()
        let toolBarPosition: ToolBarPosition = .top

        init(_ objectModel: ObjectModel,
             _ toolBarPosition: ToolBarPosition) {}
        init() {}
    }
}
