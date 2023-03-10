/*
  ObjectType.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI

enum ObjectType: Int, CaseIterable {
    case select
    case text
    case pen
    case line
    case arrow
    case fillRect
    case lineRect
    case fillOval
    case lineOval

    var symbolName: String {
        switch self {
        case .select:   return "hand.point.up.left.fill"
        case .text:     return "textbox"
        case .pen:      return "scribble"
        case .line:     return "line.diagonal"
        case .arrow:    return "line.diagonal.arrow"
        case .fillRect: return "square.fill"
        case .lineRect: return "square"
        case .fillOval: return "oval.fill"
        case .lineOval: return "oval"
        }
    }

    var help: LocalizedStringKey {
        switch self {
        case .select:   return "select"
        case .text:     return "text"
        case .pen:      return "pen"
        case .line:     return "line"
        case .arrow:    return "arrow"
        case .fillRect: return "fillRect"
        case .lineRect: return "lineRect"
        case .fillOval: return "fillOval"
        case .lineOval: return "lineOval"
        }
    }
}
