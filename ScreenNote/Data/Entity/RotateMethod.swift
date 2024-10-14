/*
  RotateMethod.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/08.
  
*/

import SwiftUI

enum RotateMethod: Int, CaseIterable, Identifiable {
    case rotateRight
    case rotateLeft

    var id: Int { rawValue }

    var angle: CGFloat {
        (self == .rotateRight ? 0.5 : -0.5) * CGFloat.pi
    }

    var symbolName: String {
        switch self {
        case .rotateRight: "rotate.right.fill"
        case .rotateLeft:  "rotate.left.fill"
        }
    }

    var help: LocalizedStringKey {
        switch self {
        case .rotateRight: "rotateRight"
        case .rotateLeft:  "rotateLeft"
        }
    }
}
