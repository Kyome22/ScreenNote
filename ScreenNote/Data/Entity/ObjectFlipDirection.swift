/*
  ObjectFlipDirection.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/08.
  
*/

import SwiftUI

enum ObjectFlipDirection: Int, CaseIterable {
    case horizontal
    case vertical

    var symbolName: String {
        switch self {
        case .horizontal:
            return "arrow.left.and.right.righttriangle.left.righttriangle.right.fill"
        case .vertical:
            return "arrow.up.and.down.righttriangle.up.righttriangle.down.fill"
        }
    }

    var help: LocalizedStringKey {
        switch self {
        case .horizontal:
            return "horizontalFlip"
        case .vertical:
            return "verticalFlip"
        }
    }
}
