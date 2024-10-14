/*
  ToolBarPosition.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI

enum ToolBarPosition: Int, CaseIterable, Identifiable {
    case top
    case right
    case bottom
    case left

    var id: Int { rawValue }

    var label: LocalizedStringKey {
        switch self {
        case .top:    "top"
        case .right:  "right"
        case .bottom: "bottom"
        case .left:   "left"
        }
    }
}
