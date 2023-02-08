/*
  ToggleMethod.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI

enum ToggleMethod: Int, CaseIterable {
    case longPressKey
    case pressBothSideKey

    var localizedKey: LocalizedStringKey {
        switch self {
        case .longPressKey:
            return "longPressModifierKey"
        case .pressBothSideKey:
            return "pressBothSideModifierKeys"
        }
    }

    var panelWidth: CGFloat {
        switch self {
        case .longPressKey:
            return 280
        case .pressBothSideKey:
            return 380
        }
    }
}
