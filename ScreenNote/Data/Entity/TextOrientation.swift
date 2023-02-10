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

    func rotateRight() -> Self {
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

    func rotateLeft() -> Self {
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

    func flipHorizontal() -> Self {
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

    func flipVertical() -> Self {
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
}
