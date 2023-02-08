/*
  WorkspaceViewModel.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/01.
  
*/

import Foundation

protocol WorkspaceViewModel: ObservableObject {
    var toolBarPosition: ToolBarPosition { get set }

    init(_ userDefaultsRepository: UserDefaultsRepository)
}

final class WorkspaceViewModelImpl<UR: UserDefaultsRepository>: WorkspaceViewModel {
    @Published var toolBarPosition: ToolBarPosition

    private let userDefaultsRepository: UR

    init(_ userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository as! UR
        toolBarPosition = userDefaultsRepository.toolBarPosition
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class WorkspaceViewModelMock: WorkspaceViewModel {
        @Published var toolBarPosition: ToolBarPosition = .top

        init(_ userDefaultsRepository: UserDefaultsRepository) {}
        init() {}
    }
}
