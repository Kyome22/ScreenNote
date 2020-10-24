//
//  FirstPopover.swift
//  ScreenNote
//
//  Created by Takuto Nakamura on 2020/10/24.
//  Copyright © 2020 Kyome. All rights reserved.
//

import Cocoa

class FirstPopover: NSPopover {

    override init() {
        super.init()
        self.contentViewController = NSViewController(nibName: "FirstPopover", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
