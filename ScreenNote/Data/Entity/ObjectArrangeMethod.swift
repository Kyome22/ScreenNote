/*
  ObjectArrangeMethod.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/08.
  
*/

import SwiftUI

enum ObjectArrangeMethod: Int, CaseIterable {
    case bringToFrontmost
    case sendToBackmost

    var symbolName: String {
        switch self {
        case .bringToFrontmost:
            return "square.3.stack.3d.top.filled"
        case .sendToBackmost:
            return "square.3.stack.3d.bottom.filled"
        }
    }

    var help: LocalizedStringKey {
        switch self {
        case .bringToFrontmost:
            return "bringFront"
        case .sendToBackmost:
            return "sendBack"
        }
    }
}
