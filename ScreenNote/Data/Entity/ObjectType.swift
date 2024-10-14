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

    var help: String {
        switch self {
        case .select:   "select"
        case .text:     "text"
        case .pen:      "pen"
        case .line:     "line"
        case .arrow:    "arrow"
        case .fillRect: "fillRect"
        case .lineRect: "lineRect"
        case .fillOval: "fillOval"
        case .lineOval: "lineOval"
        }
    }
}
