//
//  TutorialPanel.swift
//  ScreenNote
//
//  Created by Takuto Nakamura on 2019/06/12.
//  Copyright © 2019 Kyome. All rights reserved.
//

import Cocoa

class HotKeyPanel: NSPanel {
    
    private var topLbl: NSTextField!
    private var leftLbl: NSTextField!
    private var centerLbl: NSTextField!
    private var rightLbl: NSTextField!
    
    init(frame: NSRect, press: Int, key: Int) {
        super.init(contentRect: frame,
                   styleMask: [.borderless, .nonactivatingPanel],
                   backing: .buffered,
                   defer: true)
        self.level = .modalPanel
        self.collectionBehavior = [.canJoinAllSpaces]
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        
        self.contentView?.wantsLayer = true
        self.contentView?.layer?.cornerRadius = 15

        let textColor = NSColor.tutorialText
        self.contentView?.layer?.backgroundColor = CGColor.tutorialBG
        
        var modifier: (name: String, symbol: String) = ("", "")
        switch key {
        case 0: modifier = ("command".localized, "⌘")
        case 1: modifier = ("shift".localized, "⇧")
        case 2: modifier = ("option".localized, "⌥")
        case 3: modifier = ("control".localized, "⌃")
        default: break
        }
        
        if press == 0 {
            let str = "both".localized.replacingOccurrences(of: "MOD", with: modifier.name)
            topLbl = NSTextField(labelWithString: str)
            topLbl.textColor = textColor
            topLbl.font = NSFont.systemFont(ofSize: 15)
            leftLbl = NSTextField(labelWithString: modifier.symbol)
            leftLbl.textColor = textColor
            leftLbl.font = NSFont.systemFont(ofSize: 100, weight: NSFont.Weight.bold)
            rightLbl = NSTextField(labelWithString: modifier.symbol)
            rightLbl.textColor = textColor
            rightLbl.font = NSFont.systemFont(ofSize: 100, weight: NSFont.Weight.bold)
            
            self.contentView?.addSubview(topLbl)
            self.contentView?.addSubview(leftLbl)
            self.contentView?.addSubview(rightLbl)
            
            topLbl.translatesAutoresizingMaskIntoConstraints = false
            leftLbl.translatesAutoresizingMaskIntoConstraints = false
            rightLbl.translatesAutoresizingMaskIntoConstraints = false
            
            topLbl.centerXAnchor.constraint(equalTo: self.contentView!.centerXAnchor).isActive = true
            topLbl.centerYAnchor.constraint(equalTo: self.contentView!.centerYAnchor, constant: -55).isActive = true
            leftLbl.centerXAnchor.constraint(equalTo: self.contentView!.centerXAnchor, constant: -80).isActive = true
            leftLbl.centerYAnchor.constraint(equalTo: self.contentView!.centerYAnchor, constant: 15).isActive = true
            rightLbl.centerXAnchor.constraint(equalTo: self.contentView!.centerXAnchor, constant: 80).isActive = true
            rightLbl.centerYAnchor.constraint(equalTo: self.contentView!.centerYAnchor, constant: 15).isActive = true
        } else {
            let str = "long".localized.replacingOccurrences(of: "MOD", with: modifier.name)
            topLbl = NSTextField(labelWithString: str)
            topLbl.textColor = textColor
            topLbl.font = NSFont.systemFont(ofSize: 15)
            centerLbl = NSTextField(labelWithString: modifier.symbol)
            centerLbl.textColor = textColor
            centerLbl.font = NSFont.systemFont(ofSize: 100, weight: NSFont.Weight.bold)
            
            self.contentView?.addSubview(topLbl)
            self.contentView?.addSubview(centerLbl)
            
            topLbl.translatesAutoresizingMaskIntoConstraints = false
            centerLbl.translatesAutoresizingMaskIntoConstraints = false
            
            topLbl.centerXAnchor.constraint(equalTo: self.contentView!.centerXAnchor).isActive = true
            topLbl.centerYAnchor.constraint(equalTo: self.contentView!.centerYAnchor, constant: -55).isActive = true
            centerLbl.centerXAnchor.constraint(equalTo: self.contentView!.centerXAnchor).isActive = true
            centerLbl.centerYAnchor.constraint(equalTo: self.contentView!.centerYAnchor, constant: 15).isActive = true
        }
        
    }
    
    func fadeOut(callback: @escaping () -> Void) {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            self.animator().alphaValue = 0.0
        }) {
            self.close()
            callback()
        }
    }
    
}
