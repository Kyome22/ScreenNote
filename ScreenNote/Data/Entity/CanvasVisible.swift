/*
 CanvasVisible.swift
 ScreenNote

 Created by Takuto Nakamura on 2023/11/18.
 Copyright © 2023 Studio Kyome. All rights reserved.
*/

import SwiftUI

enum CanvasVisible {
    case show
    case hide

    var label: LocalizedStringKey {
        switch self {
        case .show: "hideCanvas"
        case .hide: "showCanvas"
        }
    }
}
