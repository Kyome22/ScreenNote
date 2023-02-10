/*
  FlipMethod.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/08.
  
*/

import SwiftUI

enum FlipMethod: Int, CaseIterable {
    case flipHorizontal
    case flipVertical

    var symbolName: String {
        switch self {
        case .flipHorizontal:
            return "arrow.left.and.right.righttriangle.left.righttriangle.right.fill"
        case .flipVertical:
            return "arrow.up.and.down.righttriangle.up.righttriangle.down.fill"
        }
    }

    var help: LocalizedStringKey {
        switch self {
        case .flipHorizontal:
            return "flipHorizontal"
        case .flipVertical:
            return "flipVertical"
        }
    }
}
