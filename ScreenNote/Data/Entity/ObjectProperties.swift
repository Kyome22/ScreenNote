/*
 ObjectProperties.swift
 ScreenNote

 Created by Takuto Nakamura on 2023/11/16.
 Copyright © 2023 Studio Kyome. All rights reserved.
*/

import SwiftUI

struct ObjectProperties {
    var color: Color
    var opacity: CGFloat
    var lineWidth: CGFloat

    static let `default` = Self(color: Color(.uniqueWhite), opacity: 0.8, lineWidth: 4.0)
}
