/*
  FlipMethod.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/08.
  
*/

import SwiftUI

enum FlipMethod: Int, CaseIterable, Identifiable {
    case flipHorizontal
    case flipVertical

    var id: Int { rawValue }

    var symbolName: String {
        switch self {
        case .flipHorizontal:
            "arrow.left.and.right.righttriangle.left.righttriangle.right.fill"
        case .flipVertical:
            "arrow.up.and.down.righttriangle.up.righttriangle.down.fill"
        }
    }

    var help: LocalizedStringKey {
        switch self {
        case .flipHorizontal: "flipHorizontal"
        case .flipVertical:   "flipVertical"
        }
    }
}
