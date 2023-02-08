/*
  View+Extensions.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI

extension View {
    var macOS13OrLater: Bool {
        if #available(macOS 13, *) {
            return true
        } else {
            return false
        }
    }

    func wrapText(
        maxKey: LocalizedStringKey,
        key: LocalizedStringKey
    ) -> some View {
        return Text(maxKey)
            .hidden()
            .overlay(alignment: .leading) {
                Text(key)
            }
            .fixedSize()
    }
}
