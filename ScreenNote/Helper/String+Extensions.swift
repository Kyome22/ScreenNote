/*
  String+Extensions.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import Foundation

extension String {
    var infoString: String {
        guard let str = Bundle.main.object(forInfoDictionaryKey: self) as? String else {
            fatalError("infoString key is not found.")
        }
        return str
    }
}
