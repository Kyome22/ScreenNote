/*
  RotateMethod.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/08.
  
*/

import SwiftUI

enum RotateMethod: Int, CaseIterable {
    case rotateLeft
    case rotateRight

    var angle: CGFloat {
        return (self == .rotateRight ? 0.5 : -0.5) * CGFloat.pi
    }

    var symbolName: String {
        switch self {
        case .rotateLeft:
            return "rotate.left.fill"
        case .rotateRight:
            return "rotate.right.fill"
        }
    }

    var help: LocalizedStringKey {
        switch self {
        case .rotateLeft:
            return "rotateLeft"
        case .rotateRight:
            return "rotateRight"
        }
    }
}
