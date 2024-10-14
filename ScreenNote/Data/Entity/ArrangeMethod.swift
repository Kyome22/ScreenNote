/*
  ArrangeMethod.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/08.
  
*/

import SwiftUI

enum ArrangeMethod: Int, CaseIterable {
    case bringToFrontmost
    case sendToBackmost

    var symbolName: String {
        switch self {
        case .bringToFrontmost: "square.3.stack.3d.top.filled"
        case .sendToBackmost:   "square.3.stack.3d.bottom.filled"
        }
    }

    var help: LocalizedStringKey {
        switch self {
        case .bringToFrontmost: "bringFront"
        case .sendToBackmost:   "sendBack"
        }
    }
}
