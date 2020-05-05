//
//  PreferencesVC.swift
//  ScreenNote
//
//  Created by Takuto Nakamura on 2017/07/12.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import Cocoa

class PreferencesVC: NSViewController {

    @IBOutlet weak var bothRadioButton: NSButton!
    @IBOutlet weak var longRadioButton: NSButton!
    @IBOutlet weak var modifierKeyPopUp: NSPopUpButton!
    @IBOutlet weak var positionPopUp: NSPopUpButton!
    
    let dm = DataManager.shared

	override func viewWillAppear() {
		super.viewWillAppear()
        let press = dm.press
        bothRadioButton.state = (press == 0 ? .on : .off)
        longRadioButton.state = (press != 0 ? .on : .off)
        modifierKeyPopUp.selectItem(at: dm.key)
        positionPopUp.selectItem(at: dm.position)
	}
    
    @IBAction func changedPress(_ sender: NSButton) {
        dm.press = sender.tag
        AppDelegate.shared.setTrigger()
    }
    

    @IBAction func changedModifierKey(_ sender: NSPopUpButton) {
        dm.key = sender.indexOfSelectedItem
        AppDelegate.shared.setTrigger()
    }
    
    @IBAction func changedPosition(_ sender: NSPopUpButton) {
        dm.position = sender.indexOfSelectedItem
        AppDelegate.shared.setPosition()
    }
        
}
