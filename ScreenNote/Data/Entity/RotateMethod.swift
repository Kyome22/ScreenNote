/*
  RotateMethod.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/08.
  
*/

import SwiftUI

enum RotateMethod: Int, CaseIterable {
    case rotateRight
    case rotateLeft

    var angle: CGFloat {
        return (self == .rotateRight ? 0.5 : -0.5) * CGFloat.pi
    }

    var symbolName: String {
        switch self {
        case .rotateRight:
            return "rotate.right.fill"
        case .rotateLeft:
            return "rotate.left.fill"
        }
    }

    var help: LocalizedStringKey {
        switch self {
        case .rotateRight:
            return "rotateRight"
        case .rotateLeft:
            return "rotateLeft"
        }
    }
}
