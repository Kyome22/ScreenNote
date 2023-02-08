/*
  ObjectAlignment.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/04.
  
*/

import SwiftUI

enum ObjectAlignment: Int, CaseIterable {
    case left
    case hCenter
    case right
    case top
    case vCenter
    case bottom

    var symbolName: String {
        switch self {
        case .left:    return "align.horizontal.left.fill"
        case .hCenter: return "align.horizontal.center.fill"
        case .right:   return "align.horizontal.right.fill"
        case .top:     return "align.vertical.top.fill"
        case .vCenter: return "align.vertical.center.fill"
        case .bottom:  return "align.vertical.bottom.fill"
        }
    }

    var help: LocalizedStringKey {
        switch self {
        case .left:    return "horizontalAlignLeft"
        case .hCenter: return "horizontalAlignCenter"
        case .right:   return "horizontalAlignRight"
        case .top:     return "verticalAlignTop"
        case .vCenter: return "verticalAlignCenter"
        case .bottom:  return "verticalAlignBottom"
        }
    }

    static let horizontals: [ObjectAlignment] = [
        .left, .hCenter, .right
    ]

    static let verticals: [ObjectAlignment] = [
        .top, .vCenter, .bottom
    ]
}
