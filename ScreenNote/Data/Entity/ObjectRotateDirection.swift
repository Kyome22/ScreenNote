/*
  ObjectRotateDirection.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/08.
  
*/

import SwiftUI

enum ObjectRotateDirection: Int, CaseIterable {
    case counterClockwise
    case clockwise

    var angle: CGFloat {
        return (self == .clockwise ? 0.5 : -0.5) * CGFloat.pi
    }

    var symbolName: String {
        switch self {
        case .counterClockwise:
            return "rotate.left.fill"
        case .clockwise:
            return "rotate.right.fill"
        }
    }

    var help: LocalizedStringKey {
        switch self {
        case .counterClockwise:
            return "rotateCounterClockwise"
        case .clockwise:
            return "rotateClockwise"
        }
    }
}
