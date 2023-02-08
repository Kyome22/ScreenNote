/*
  Anchor.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import CoreGraphics

enum Anchor: Int, CaseIterable {
    case topLeft
    case top
    case topRight
    case left
    case right
    case bottomLeft
    case bottom
    case bottomRight

    func center(with bounds: CGRect) -> CGPoint {
        switch self {
        case .topLeft:     return CGPoint(x: bounds.minX, y: bounds.minY)
        case .top:         return CGPoint(x: bounds.midX, y: bounds.minY)
        case .topRight:    return CGPoint(x: bounds.maxX, y: bounds.minY)
        case .left:        return CGPoint(x: bounds.minX, y: bounds.midY)
        case .right:       return CGPoint(x: bounds.maxX, y: bounds.midY)
        case .bottomLeft:  return CGPoint(x: bounds.minX, y: bounds.maxY)
        case .bottom:      return CGPoint(x: bounds.midX, y: bounds.maxY)
        case .bottomRight: return CGPoint(x: bounds.maxX, y: bounds.maxY)
        }
    }

    func resize(bounds: CGRect, with diff: CGPoint) -> CGRect {
        // CGRect.size.width と CGRect.width は異なるので注意
        // 後者は正規化されて正の値になる
        let size = CGSize(width: bounds.width, height: bounds.height)
        var b = CGRect(origin: bounds.origin, size: size)
        switch self {
        case .topLeft:
            b.origin.x += diff.x
            b.origin.y += diff.y
            b.size.width -= diff.x
            b.size.height -= diff.y
        case .top:
            b.origin.y += diff.y
            b.size.height -= diff.y
        case .topRight:
            b.origin.y += diff.y
            b.size.width += diff.x
            b.size.height -= diff.y
        case .left:
            b.origin.x += diff.x
            b.size.width -= diff.x
        case .right:
            b.size.width += diff.x
        case .bottomLeft:
            b.origin.x += diff.x
            b.size.width -= diff.x
            b.size.height += diff.y
        case .bottom:
            b.size.height += diff.y
        case .bottomRight:
            b.size.width += diff.x
            b.size.height += diff.y
        }
        return b
    }
}
