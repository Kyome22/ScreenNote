/*
 ModifierFlag+Extensions.swift
 ScreenNote

 Created by Takuto Nakamura on 2023/11/18.
 Copyright © 2023 Studio Kyome. All rights reserved.
*/

import SwiftUI
import SpiceKey

extension ModifierFlag {
    var localizedTitle: String {
        return String(localized: .init(title))
    }

    var label: LocalizedStringKey {
        return LocalizedStringKey("\(string)\(localizedTitle)key")
    }
}
