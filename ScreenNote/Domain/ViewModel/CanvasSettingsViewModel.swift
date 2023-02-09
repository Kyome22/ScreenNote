/*
  CanvasSettingsViewModel.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/08.
  
*/

import SwiftUI

protocol CanvasSettingsViewModel: ObservableObject {
    var clearAllObjects: Bool { get set }
    var showColorPopover: Bool { get set }
    var defaultColor: Color { get set }
    var defaultOpacity: CGFloat { get set }
    var defaultLineWidth: CGFloat { get set }
    var colors: [[Color]] { get }

    init(_ userDefaultsRepository: UserDefaultsRepository)

    func endUpdatingDefaultOpacity()
    func endUpdatingDefaultLineWidth()
}

final class CanvasSettingsViewModelImpl<UR: UserDefaultsRepository>: CanvasSettingsViewModel {
    @Published var clearAllObjects: Bool {
        didSet { userDefaultsRepository.clearAllObjects = clearAllObjects }
    }
    @Published var showColorPopover: Bool = false
    @Published var defaultColor: Color {
        didSet { updatedColor() }
    }
    @Published var defaultOpacity: CGFloat
    @Published var defaultLineWidth: CGFloat
    let colors: [[Color]]
    private let userDefaultsRepository: UR

    init(_ userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository as! UR
        clearAllObjects = userDefaultsRepository.clearAllObjects
        colors = Color.palette
        let index = userDefaultsRepository.defaultColorIndex
        defaultColor = colors[index % 8][index / 8]
        defaultOpacity = userDefaultsRepository.defaultOpacity
        defaultLineWidth = userDefaultsRepository.defaultLineWidth
    }

    private func updatedColor() {
        for i in (0 ..< 40) {
            if colors[i % 8][i / 8] == defaultColor {
                userDefaultsRepository.defaultColorIndex = i
            }
        }
    }

    func endUpdatingDefaultOpacity() {
        userDefaultsRepository.defaultOpacity = defaultOpacity
    }

    func endUpdatingDefaultLineWidth() {
        userDefaultsRepository.defaultLineWidth = defaultLineWidth
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class CanvasSettingsViewModelMock: CanvasSettingsViewModel {
        @Published var clearAllObjects: Bool = false
        @Published var defaultColorIndex: Int = 0
        @Published var showColorPopover: Bool = false
        @Published var defaultColor: Color = .clear
        @Published var defaultOpacity: CGFloat = 0.8
        @Published var defaultLineWidth: CGFloat = 4.0
        let colors: [[Color]]

        init(_ userDefaultsRepository: UserDefaultsRepository) {
            colors = []
        }
        init() {
            colors = Color.palette
            defaultColor = colors[0][0]
        }

        func endUpdatingDefaultOpacity() {}
        func endUpdatingDefaultLineWidth() {}
    }
}
