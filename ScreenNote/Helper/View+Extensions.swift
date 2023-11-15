/*
  View+Extensions.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI

extension View {
    func wrapText(
        maxKey: LocalizedStringKey,
        key: LocalizedStringKey
    ) -> some View {
        return Text(maxKey)
            .hidden()
            .overlay(alignment: .trailing) {
                Text(key)
            }
            .fixedSize()
    }
}
