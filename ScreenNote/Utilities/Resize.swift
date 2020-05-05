//
//  Resize.swift
//  ScreenNote
//
//  Created by Takuto Nakamura on 2020/05/06.
//  Copyright © 2020 Kyome. All rights reserved.
//

import Cocoa

enum Anchor: Int {
    case topLeft
    case top
    case topRight
    case right
    case bottomRight
    case bottom
    case bottomLeft
    case left
}

struct ResizeSize {
    var width: CGFloat
    var height: CGFloat
}

struct ResizeRect {
    var origin: CGPoint
    var size: ResizeSize
    var width: CGFloat { return size.width }
    var height: CGFloat { return size.height }
    
    init(_ origin: CGPoint, _ size: ResizeSize) {
        self.origin = origin
        self.size = size
    }
    
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        origin = CGPoint(x: x, y: y)
        size = ResizeSize(width: width, height: height)
    }
    
    init(_ bounds: CGRect) {
        origin = bounds.origin
        size = ResizeSize(width: bounds.width, height: bounds.height)
    }
}
