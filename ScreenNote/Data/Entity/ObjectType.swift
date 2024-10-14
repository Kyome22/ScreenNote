/*
  ObjectType.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI

enum ObjectType: Int, CaseIterable, Identifiable {
    case select
    case text
    case pen
    case line
    case arrow
    case fillRect
    case lineRect
    case fillOval
    case lineOval

    var id: Int { rawValue }

    var symbolName: String {
        switch self {
        case .select:   "hand.point.up.left.fill"
        case .text:     "textbox"
        case .pen:      "scribble"
        case .line:     "line.diagonal"
        case .arrow:    "line.diagonal.arrow"
        case .fillRect: "square.fill"
        case .lineRect: "square"
        case .fillOval: "oval.fill"
        case .lineOval: "oval"
        }
    }

    var label: LocalizedStringKey {
        switch self {
        case .select:   "toolSelect"
        case .text:     "toolText"
        case .pen:      "toolPen"
        case .line:     "toolLine"
        case .arrow:    "toolArrow"
        case .fillRect: "toolFillRect"
        case .lineRect: "toolLineRect"
        case .fillOval: "toolFillOval"
        case .lineOval: "toolLineOval"
        }
    }

    var help: LocalizedStringKey {
        switch self {
        case .select:   "helpSelect"
        case .text:     "helpText"
        case .pen:      "helpPen"
        case .line:     "helpLine"
        case .arrow:    "helpArrow"
        case .fillRect: "helpFillRect"
        case .lineRect: "helpLineRect"
        case .fillOval: "helpFillOval"
        case .lineOval: "helpLineOval"
        }
    }

    static let defaultObjects: [ObjectType] = [
        .text, .pen, .line, .arrow, .fillRect, .lineRect, .fillOval, .lineOval
    ]
}
