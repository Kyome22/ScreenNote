/*
 InputTextProperties.swift
 ScreenNote

 Created by Takuto Nakamura on 2023/11/16.
 Copyright © 2023 Studio Kyome. All rights reserved.
*/

import Foundation

struct InputTextProperties {
    var object: Object
    var inputText: String
    var fontSize: CGFloat

    var inputTextOffset: CGSize {
        CGSize(width: object.bounds.minX, height: object.bounds.minY)
    }
}
