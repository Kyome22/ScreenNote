/*
  ToolBarPosition.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI

enum ToolBarPosition: Int, CaseIterable {
    case top
    case right
    case bottom
    case left

    var label: LocalizedStringKey {
        switch self {
        case .top:    return "top"
        case .right:  return "right"
        case .bottom: return "bottom"
        case .left:   return "left"
        }
    }
}
