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
    var defaultObjectType: ObjectType { get set }
    var defaultColorIndex: Int { get set }
    var defaultOpacity: CGFloat { get set }
    var defaultLineWidth: CGFloat { get set }
    var backgroundColorIndex: Int { get set }
    var backgroundOpacity: CGFloat { get set }
    var colors: [[Color]] { get }
    var defaultColor: Color { get }
    var backgrounds: [Color] { get }

    init(_ userDefaultsRepository: UserDefaultsRepository)

    func updateDefaultColor(_ index: Int)
    func updateBackgroundColor(_ index: Int)
    func endUpdatingDefaultOpacity()
    func endUpdatingDefaultLineWidth()
    func endUpdatingBackgroundOpacity()
}

final class CanvasSettingsViewModelImpl: CanvasSettingsViewModel {
    @Published var clearAllObjects: Bool {
        didSet { userDefaultsRepository.clearAllObjects = clearAllObjects }
    }
    @Published var showColorPopover: Bool = false
    @Published var defaultObjectType: ObjectType {
        didSet { userDefaultsRepository.defaultObjectType = defaultObjectType }
    }
    @Published var defaultColorIndex: Int
    @Published var defaultOpacity: CGFloat
    @Published var defaultLineWidth: CGFloat
    @Published var backgroundColorIndex: Int
    @Published var backgroundOpacity: CGFloat
    let colors: [[Color]]
    let backgrounds: [Color] = [.white, .black]
    private let userDefaultsRepository: UserDefaultsRepository

    var defaultColor: Color {
        colors[defaultColorIndex % 8][defaultColorIndex / 8]
    }

    init(_ userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
        clearAllObjects = userDefaultsRepository.clearAllObjects
        colors = Color.palette
        defaultObjectType = userDefaultsRepository.defaultObjectType
        defaultColorIndex = userDefaultsRepository.defaultColorIndex
        defaultOpacity = userDefaultsRepository.defaultOpacity
        defaultLineWidth = userDefaultsRepository.defaultLineWidth
        backgroundColorIndex = userDefaultsRepository.backgroundColorIndex
        backgroundOpacity = userDefaultsRepository.backgroundOpacity
    }

    func updateDefaultColor(_ index: Int) {
        defaultColorIndex = index
        userDefaultsRepository.defaultColorIndex = index
    }

    func updateBackgroundColor(_ index: Int) {
        backgroundColorIndex = index
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
        @Published var defaultObjectType: ObjectType = .pen
        @Published var defaultColorIndex: Int = 0
        @Published var showColorPopover: Bool = false
        @Published var defaultColor: Color = .clear
        @Published var defaultOpacity: CGFloat = 0.8
        @Published var defaultLineWidth: CGFloat = 4.0
        @Published var backgroundColorIndex: Int = 0
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

        func updateDefaultColor(_ index: Int) {}
        func updateBackgroundColor(_ index: Int) {}
        func endUpdatingDefaultOpacity() {}
        func endUpdatingDefaultLineWidth() {}
        func endUpdatingBackgroundOpacity() {}
    }
}
