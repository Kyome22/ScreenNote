/*
  AlignMethod.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/04.
  
*/

import SwiftUI

enum AlignMethod: Int, CaseIterable, Identifiable {
    case horizontalAlignLeft
    case horizontalAlignCenter
    case horizontalAlignRight
    case verticalAlignTop
    case verticalAlignCenter
    case verticalAlignBottom

    var id: Int { rawValue }

    var symbolName: String {
        switch self {
        case .horizontalAlignLeft:   "align.horizontal.left.fill"
        case .horizontalAlignCenter: "align.horizontal.center.fill"
        case .horizontalAlignRight:  "align.horizontal.right.fill"
        case .verticalAlignTop:      "align.vertical.top.fill"
        case .verticalAlignCenter:   "align.vertical.center.fill"
        case .verticalAlignBottom:   "align.vertical.bottom.fill"
        }
    }

    var help: LocalizedStringKey {
        switch self {
        case .horizontalAlignLeft:   "horizontalAlignLeft"
        case .horizontalAlignCenter: "horizontalAlignCenter"
        case .horizontalAlignRight:  "horizontalAlignRight"
        case .verticalAlignTop:      "verticalAlignTop"
        case .verticalAlignCenter:   "verticalAlignCenter"
        case .verticalAlignBottom:   "verticalAlignBottom"
        }
    }

    static let horizontals: [AlignMethod] = [
        .horizontalAlignLeft, .horizontalAlignCenter, .horizontalAlignRight
    ]

    static let verticals: [AlignMethod] = [
        .verticalAlignTop, .verticalAlignCenter, .verticalAlignBottom
    ]
}
