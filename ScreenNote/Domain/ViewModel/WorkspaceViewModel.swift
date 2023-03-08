/*
  WorkspaceViewModel.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/01.
  
*/

import Foundation

protocol WorkspaceViewModel: ObservableObject {
    var toolBarPosition: ToolBarPosition { get set }

    init(_ toolBarPosition: ToolBarPosition)
}

final class WorkspaceViewModelImpl: WorkspaceViewModel {
    @Published var toolBarPosition: ToolBarPosition

    init(_ toolBarPosition: ToolBarPosition) {
        self.toolBarPosition = toolBarPosition
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class WorkspaceViewModelMock: WorkspaceViewModel {
        @Published var toolBarPosition: ToolBarPosition = .top

        init(_ toolBarPosition: ToolBarPosition) {}
        init() {}
    }
}
