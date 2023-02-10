/*
  AlignMethod.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/04.
  
*/

import SwiftUI

enum AlignMethod: Int, CaseIterable {
    case horizontalAlignLeft
    case horizontalAlignCenter
    case horizontalAlignRight
    case verticalAlignTop
    case verticalAlignCenter
    case verticalAlignBottom

    var symbolName: String {
        switch self {
        case .horizontalAlignLeft:
            return "align.horizontal.left.fill"
        case .horizontalAlignCenter:
            return "align.horizontal.center.fill"
        case .horizontalAlignRight:
            return "align.horizontal.right.fill"
        case .verticalAlignTop:
            return "align.vertical.top.fill"
        case .verticalAlignCenter:
            return "align.vertical.center.fill"
        case .verticalAlignBottom:
            return "align.vertical.bottom.fill"
        }
    }

    var help: LocalizedStringKey {
        switch self {
        case .horizontalAlignLeft:
            return "horizontalAlignLeft"
        case .horizontalAlignCenter:
            return "horizontalAlignCenter"
        case .horizontalAlignRight:
            return "horizontalAlignRight"
        case .verticalAlignTop:
            return "verticalAlignTop"
        case .verticalAlignCenter:
            return "verticalAlignCenter"
        case .verticalAlignBottom:
            return "verticalAlignBottom"
        }
    }

    static let horizontals: [AlignMethod] = [
        .horizontalAlignLeft, .horizontalAlignCenter, .horizontalAlignRight
    ]

    static let verticals: [AlignMethod] = [
        .verticalAlignTop, .verticalAlignCenter, .verticalAlignBottom
    ]
}
