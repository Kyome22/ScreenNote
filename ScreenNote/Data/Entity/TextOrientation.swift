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
        case .up:            Angle(degrees: 0)
        case .right:         Angle(degrees: 90)
        case .down:          Angle(degrees: 180)
        case .left:          Angle(degrees: 270)
        case .upMirrored:    Angle(degrees: 0)
        case .rightMirrored: Angle(degrees: 90)
        case .downMirrored:  Angle(degrees: 180)
        case .leftMirrored:  Angle(degrees: 270)
        }
    }

    var scale: CGFloat {
        switch self {
        case .up, .right, .down, .left: 
            1.0
        case .upMirrored, .rightMirrored, .downMirrored, .leftMirrored: 
            -1.0
        }
    }

    var angle3D: Angle {
        switch self {
        case .up:            Angle(degrees: 0)
        case .right:         Angle(degrees: 90)
        case .down:          Angle(degrees: 180)
        case .left:          Angle(degrees: 270)
        case .upMirrored:    Angle(degrees: 180)
        case .rightMirrored: Angle(degrees: 180)
        case .downMirrored:  Angle(degrees: 180)
        case .leftMirrored:  Angle(degrees: 180)
        }
    }

    var axis: (x: CGFloat, y: CGFloat, z: CGFloat) {
        switch self {
        case .up:            (x: 0_, y: 0, z: 1)
        case .right:         (x: 0_, y: 0, z: 1)
        case .down:          (x: 0_, y: 0, z: 1)
        case .left:          (x: 0_, y: 0, z: 1)
        case .upMirrored:    (x: 0_, y: 1, z: 0)
        case .rightMirrored: (x: 1_, y: 1, z: 0)
        case .downMirrored:  (x: 1_, y: 0, z: 0)
        case .leftMirrored:  (x: -1, y: 1, z: 0)
        }
    }

    func size(of bounds: CGRect) -> CGSize {
        switch self {
        case .up, .down, .upMirrored, .downMirrored:
            CGSize(width: bounds.width, height: bounds.height)
        case .right, .left, .rightMirrored, .leftMirrored:
            CGSize(width: bounds.height, height: bounds.width)
        }
    }

    private func rotateRight() -> Self {
        switch self {
        case .up:            .right
        case .right:         .down
        case .down:          .left
        case .left:          .up
        case .upMirrored:    .leftMirrored
        case .rightMirrored: .upMirrored
        case .downMirrored:  .rightMirrored
        case .leftMirrored:  .downMirrored
        }
    }

    private func rotateLeft() -> Self {
        switch self {
        case .up:            .left
        case .right:         .up
        case .down:          .right
        case .left:          .down
        case .upMirrored:    .rightMirrored
        case .rightMirrored: .downMirrored
        case .downMirrored:  .leftMirrored
        case .leftMirrored:  .upMirrored
        }
    }

    func rotate(_ rotateMethod: RotateMethod) -> Self {
        switch rotateMethod {
        case .rotateRight: rotateRight()
        case .rotateLeft:  rotateLeft()
        }
    }

    private func flipHorizontal() -> Self {
        switch self {
        case .up:            .upMirrored
        case .right:         .rightMirrored
        case .down:          .downMirrored
        case .left:          .leftMirrored
        case .upMirrored:    .up
        case .rightMirrored: .right
        case .downMirrored:  .down
        case .leftMirrored:  .left
        }
    }

    private func flipVertical() -> Self {
        switch self {
        case .up:            .downMirrored
        case .right:         .leftMirrored
        case .down:          .upMirrored
        case .left:          .rightMirrored
        case .upMirrored:    .down
        case .rightMirrored: .left
        case .downMirrored:  .up
        case .leftMirrored:  .right
        }
    }

    func flip(_ flipMethod: FlipMethod) -> Self {
        switch flipMethod {
        case .flipHorizontal: flipHorizontal()
        case .flipVertical:   flipVertical()
        }
    }

    func endPosition(with position: CGPoint, size: CGSize) -> CGPoint {
        switch self {
        case .up:            CGPoint(x: position.x + size.width, y: position.y + size.height)
        case .right:         CGPoint(x: position.x - size.height, y: position.y + size.width)
        case .down:          CGPoint(x: position.x - size.width, y: position.y - size.height)
        case .left:          CGPoint(x: position.x + size.height, y: position.y - size.width)
        case .upMirrored:    CGPoint(x: position.x - size.width, y: position.y + size.height)
        case .rightMirrored: CGPoint(x: position.x + size.height, y: position.y + size.width)
        case .downMirrored:  CGPoint(x: position.x + size.width, y: position.y - size.height)
        case .leftMirrored:  CGPoint(x: position.x - size.height, y: position.y - size.width)
        }
    }
}
