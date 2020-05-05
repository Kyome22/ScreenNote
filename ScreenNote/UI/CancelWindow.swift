//
//  CancelWindow.swift
//  ScreenNote
//
//  Created by Takuto Nakamura on 2020/05/03.
//  Copyright © 2020 Kyome. All rights reserved.
//

import Cocoa

class CancelWindow: NSWindow {

    override func cancelOperation(_ sender: Any?) {
        self.close()
    }
    
}
