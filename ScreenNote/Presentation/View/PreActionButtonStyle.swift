/*
 PreActionButtonStyle.swift
 ScreenNote

 Created by Takuto Nakamura on 2024/10/14.
 Copyright © 2024 Studio Kyome. All rights reserved.
*/

import SwiftUI

@available(macOS 14.0, *)
struct PreActionButtonStyle: PrimitiveButtonStyle {
    let preAction: () -> Void

    init(preAction: @escaping () -> Void) {
        self.preAction = preAction
    }

    func makeBody(configuration: Configuration) -> some View {
        Button(role: configuration.role) {
            preAction()
            configuration.trigger()
        } label: {
            configuration.label
        }
    }
}

@available(macOS 14.0, *)
struct PreActionButtonStyleModifier: ViewModifier {
    let preAction: () -> Void

    init(preAction: @escaping () -> Void) {
        self.preAction = preAction
    }

    func body(content: Content) -> some View {
        content.buttonStyle(PreActionButtonStyle(preAction: preAction))
    }
}

@available(macOS 14.0, *)
extension View {
    func preActionButtonStyle(preAction: @escaping () -> Void) -> some View {
        modifier(PreActionButtonStyleModifier(preAction: preAction))
    }
}
