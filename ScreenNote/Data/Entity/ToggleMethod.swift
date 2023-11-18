/*
  ToggleMethod.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI

enum ToggleMethod: Int, CaseIterable {
    case longPressKey
    case pressBothSideKeys

    var label: LocalizedStringKey {
        switch self {
        case .longPressKey:
            return "longPressModifierKey"
        case .pressBothSideKeys:
            return "pressBothSideModifierKeys"
        }
    }

    var panelWidth: CGFloat {
        switch self {
        case .longPressKey:
            return 280
        case .pressBothSideKeys:
            return 380
        }
    }
}
