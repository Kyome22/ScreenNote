/*
  Color+Extensions.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/10.
  
*/

import SwiftUI

extension Color {
    static var palette: [[Color]] {
        return NSColor.primaries.map { primary in
            return (0 ..< 5).map { i in
                Color(primary.blended(withFraction: 0.2 * CGFloat(i), of: .black)!)
            }
        }
    }
}
