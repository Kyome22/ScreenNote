/*
  Utils.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import Foundation

func logput(
    _ items: Any...,
    file: String = #file,
    line: Int = #line,
    function: String = #function
) {
#if DEBUG
    let fileName = URL(fileURLWithPath: file).lastPathComponent
    var array: [Any] = ["💫Log: \(fileName)", "Line:\(line)", function]
    array.append(contentsOf: items)
    Swift.print(array)
#endif
}

let NOT_IMPLEMENTED = "not implemented"
struct PreviewMock {}

func + (l: CGPoint, r: CGPoint) -> CGPoint {
    return CGPoint(x: l.x + r.x, y: l.y + r.y)
}

func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

func - (l: CGPoint, r: CGPoint) -> CGPoint {
    return CGPoint(x: l.x - r.x, y: l.y - r.y)
}

func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
}

func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}

func += (left: inout CGSize, right: CGSize) {
    left = left + right
}

func - (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

func -= (left: inout CGSize, right: CGSize) {
    left = left - right
}

func * (left: CGFloat, right: CGPoint) -> CGPoint {
    return CGPoint(x: left * right.x, y: left * right.y)
}

func * (left: CGFloat, right: CGSize) -> CGSize {
    return CGSize(width: left * right.width, height: left * right.height)
}
