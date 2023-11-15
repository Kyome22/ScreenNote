/*
 CanvasSettingsViewModel.swift
 ScreenNote

 Created by Takuto Nakamura on 2023/02/08.
 Copyright © 2023 Studio Kyome. All rights reserved.
*/

import SwiftUI

protocol CanvasSettingsViewModel: ObservableObject {
    var clearAllObjects: Bool { get set }
    var showColorPopover: Bool { get set }
    var defaultColor: Color { get set }
    var defaultOpacity: CGFloat { get set }
    var defaultLineWidth: CGFloat { get set }
    var backgroundColor: Color { get set }
    var backgroundOpacity: CGFloat { get set }
    var colors: [[Color]] { get }
    var backgrounds: [Color] { get }

    init(_ userDefaultsRepository: UserDefaultsRepository)

    func endUpdatingDefaultOpacity()
    func endUpdatingDefaultLineWidth()
    func endUpdatingBackgroundOpacity()
}

final class CanvasSettingsViewModelImpl: CanvasSettingsViewModel {
    @Published var clearAllObjects: Bool {
        didSet { userDefaultsRepository.clearAllObjects = clearAllObjects }
    }
    @Published var showColorPopover: Bool = false
    @Published var defaultColor: Color {
        didSet { updatedDefaultColor() }
    }
    @Published var defaultOpacity: CGFloat
    @Published var defaultLineWidth: CGFloat
    @Published var backgroundColor: Color {
        didSet { updatedBackgroundColor() }
    }
    @Published var backgroundOpacity: CGFloat
    let colors: [[Color]]
    let backgrounds: [Color] = [.white, .black]
    private let userDefaultsRepository: UserDefaultsRepository

    init(_ userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
        clearAllObjects = userDefaultsRepository.clearAllObjects
        colors = Color.palette
        let index = userDefaultsRepository.defaultColorIndex
        defaultColor = colors[index % 8][index / 8]
        defaultOpacity = userDefaultsRepository.defaultOpacity
        defaultLineWidth = userDefaultsRepository.defaultLineWidth
        backgroundColor = backgrounds[userDefaultsRepository.backgroundColorIndex]
        backgroundOpacity = userDefaultsRepository.backgroundOpacity
    }

    private func updatedDefaultColor() {
        for i in (0 ..< 40) {
            if colors[i % 8][i / 8] == defaultColor {
                userDefaultsRepository.defaultColorIndex = i
            }
        }
    }

    private func updatedBackgroundColor() {
        let index = backgrounds.firstIndex(of: backgroundColor) ?? 0
        userDefaultsRepository.backgroundColorIndex = index
    }

    func endUpdatingDefaultOpacity() {
        userDefaultsRepository.defaultOpacity = defaultOpacity
    }

    func endUpdatingDefaultLineWidth() {
        userDefaultsRepository.defaultLineWidth = defaultLineWidth
    }

    func endUpdatingBackgroundOpacity() {
        userDefaultsRepository.backgroundOpacity = backgroundOpacity
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
        @Published var backgroundColor: Color = .white
        @Published var backgroundOpacity: CGFloat = 0.0
        let colors: [[Color]]
        let backgrounds: [Color] = [.white, .black]

        init(_ userDefaultsRepository: UserDefaultsRepository) {
            colors = []
        }
        init() {
            colors = Color.palette
            defaultColor = colors[0][0]
        }

        func endUpdatingDefaultOpacity() {}
        func endUpdatingDefaultLineWidth() {}
        func endUpdatingBackgroundOpacity() {}
    }
}
