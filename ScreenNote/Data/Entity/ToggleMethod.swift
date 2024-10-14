/*
  ToggleMethod.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI

enum ToggleMethod: Int, CaseIterable, Identifiable {
    case longPressKey
    case pressBothSideKeys

    var id: Int { rawValue }

    var label: LocalizedStringKey {
        switch self {
        case .longPressKey:      "longPressModifierKey"
        case .pressBothSideKeys: "pressBothSideModifierKeys"
        }
    }

    var panelWidth: CGFloat {
        switch self {
        case .longPressKey:      280
        case .pressBothSideKeys: 380
        }
    }
}
