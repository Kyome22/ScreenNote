/*
  TextOrientation.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/10.
  
*/

import SwiftUI

enum TextOrientation: Int, CaseIterable {
    case up
    case right
    case down
    case left
    case upMirrored
    case rightMirrored
    case downMirrored
    case leftMirrored

    var angle: Angle {
        switch self {
        case .up:            return Angle(degrees: 0)
        case .right:         return Angle(degrees: 90)
        case .down:          return Angle(degrees: 180)
        case .left:          return Angle(degrees: 270)
        case .upMirrored:    return Angle(degrees: 0)
        case .rightMirrored: return Angle(degrees: 90)
        case .downMirrored:  return Angle(degrees: 180)
        case .leftMirrored:  return Angle(degrees: 270)
        }
    }

    var scale: CGFloat {
        switch self {
        case .up, .right, .down, .left:
            return 1.0
        case .upMirrored, .rightMirrored, .downMirrored, .leftMirrored:
            return -1.0
        }
    }

    var angle3D: Angle {
        switch self {
        case .up:            return Angle(degrees: 0)
        case .right:         return Angle(degrees: 90)
        case .down:          return Angle(degrees: 180)
        case .left:          return Angle(degrees: 270)
        case .upMirrored:    return Angle(degrees: 180)
        case .rightMirrored: return Angle(degrees: 180)
        case .downMirrored:  return Angle(degrees: 180)
        case .leftMirrored:  return Angle(degrees: 180)
        }
    }

    var axis: (x: CGFloat, y: CGFloat, z: CGFloat) {
        switch self {
        case .up:            return (x: 0_, y: 0, z: 1)
        case .right:         return (x: 0_, y: 0, z: 1)
        case .down:          return (x: 0_, y: 0, z: 1)
        case .left:          return (x: 0_, y: 0, z: 1)
        case .upMirrored:    return (x: 0_, y: 1, z: 0)
        case .rightMirrored: return (x: 1_, y: 1, z: 0)
        case .downMirrored:  return (x: 1_, y: 0, z: 0)
        case .leftMirrored:  return (x: -1, y: 1, z: 0)
        }
    }

    func size(of bounds: CGRect) -> CGSize {
        switch self {
        case .up, .down, .upMirrored, .downMirrored:
            return CGSize(width: bounds.width, height: bounds.height)
        case .right, .left, .rightMirrored, .leftMirrored:
            return CGSize(width: bounds.height, height: bounds.width)
        }
    }

    private func rotateRight() -> Self {
        switch self {
        case .up:            return .right
        case .right:         return .down
        case .down:          return .left
        case .left:          return .up
        case .upMirrored:    return .leftMirrored
        case .rightMirrored: return .upMirrored
        case .downMirrored:  return .rightMirrored
        case .leftMirrored:  return .downMirrored
        }
    }

    private func rotateLeft() -> Self {
        switch self {
        case .up:            return .left
        case .right:         return .up
        case .down:          return .right
        case .left:          return .down
        case .upMirrored:    return .rightMirrored
        case .rightMirrored: return .downMirrored
        case .downMirrored:  return .leftMirrored
        case .leftMirrored:  return .upMirrored
        }
    }

    func rotate(_ rotateMethod: RotateMethod) -> Self {
        switch rotateMethod {
        case .rotateRight:
            return rotateRight()
        case .rotateLeft:
            return rotateLeft()
        }
    }

    private func flipHorizontal() -> Self {
        switch self {
        case .up:            return .upMirrored
        case .right:         return .rightMirrored
        case .down:          return .downMirrored
        case .left:          return .leftMirrored
        case .upMirrored:    return .up
        case .rightMirrored: return .right
        case .downMirrored:  return .down
        case .leftMirrored:  return .left
        }
    }

    private func flipVertical() -> Self {
        switch self {
        case .up:            return .downMirrored
        case .right:         return .leftMirrored
        case .down:          return .upMirrored
        case .left:          return .rightMirrored
        case .upMirrored:    return .down
        case .rightMirrored: return .left
        case .downMirrored:  return .up
        case .leftMirrored:  return .right
        }
    }

    func flip(_ flipMethod: FlipMethod) -> Self {
        switch flipMethod {
        case .flipHorizontal:
            return flipHorizontal()
        case .flipVertical:
            return flipVertical()
        }
    }

    func endPosition(with position: CGPoint, size: CGSize) -> CGPoint {
        switch self {
        case .up:
            return CGPoint(x: position.x + size.width, y: position.y + size.height)
        case .right:
            return CGPoint(x: position.x - size.height, y: position.y + size.width)
        case .down:
            return CGPoint(x: position.x - size.width, y: position.y - size.height)
        case .left:
            return CGPoint(x: position.x + size.height, y: position.y - size.width)
        case .upMirrored:
            return CGPoint(x: position.x - size.width, y: position.y + size.height)
        case .rightMirrored:
            return CGPoint(x: position.x + size.height, y: position.y + size.width)
        case .downMirrored:
            return CGPoint(x: position.x + size.width, y: position.y - size.height)
        case .leftMirrored:
            return CGPoint(x: position.x - size.height, y: position.y - size.width)
        }
    }
}
