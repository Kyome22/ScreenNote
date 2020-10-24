//
//  NotePanel.swift
//  ScreenNote
//
//  Created by Takuto Nakamura on 2019/06/08.
//  Copyright © 2019 Kyome. All rights reserved.
//

import Cocoa
import SpiceKey

class NotePanel: NSPanel {

    private var toolView: ToolView!
    private var noteView: NoteView!
    private var toolViewTopConstraint: NSLayoutConstraint!
    private var noteViewTopConstraint: NSLayoutConstraint!
    private let om = ObjectManager.shared
    private var monitors = [Any?]()
    private var point: CGPoint {
        return NSEvent.mouseLocation - (self.frame.origin + noteView.frame.origin)
    }
    private var isValid: Bool = false
    
    init(_ frame: NSRect) {
        super.init(contentRect: frame,
                   styleMask: [.borderless, .nonactivatingPanel],
                   backing: .buffered,
                   defer: true)
        self.level = .popUpMenu
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isOpaque = false
        self.hasShadow = false
        self.backgroundColor = NSColor(white: 0.0, alpha: 0.01)
        self.alphaValue = 0.0
        setViews()
        setMonitors()
    }
    
    override func close() {
        for monitor in monitors {
            NSEvent.removeMonitor(monitor!)
        }
        monitors.removeAll()
        super.close()
    }
    
    override var canBecomeKey: Bool {
        return true
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if firstResponder === toolView.textField.currentEditor() {
            return super.performKeyEquivalent(with: event)
        }
        return true
    }
    
    private func setViews() {
        let nib = NSNib(nibNamed: "Tool", bundle: Bundle.main)!
        var topLevelArray: NSArray? = nil
        guard
            nib.instantiate(withOwner: nil, topLevelObjects: &topLevelArray),
            let results = topLevelArray as? [Any],
            let item = results.last(where: { $0 is ToolView }),
            let view = item as? ToolView else {
                fadeOut()
                return
        }
        toolView = view
        contentView?.addSubview(toolView)
        noteView = NoteView()
        contentView?.addSubview(noteView)
        
        let noteHeight: CGFloat = frame.height - 45.0
        toolView.translatesAutoresizingMaskIntoConstraints = false
        noteView.translatesAutoresizingMaskIntoConstraints = false
        
        toolView.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        toolView.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        toolView.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
        
        noteView.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        noteView.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        noteView.heightAnchor.constraint(equalToConstant: noteHeight).isActive = true
        
        let position = AppDelegate.shared.position
        toolViewTopConstraint = toolView.topAnchor.constraint(
            equalTo: contentView!.topAnchor, constant: (position == 0 ? 0.0 : noteHeight))
        toolViewTopConstraint.isActive = true
        noteViewTopConstraint = noteView.topAnchor.constraint(
            equalTo: contentView!.topAnchor, constant: (position == 0 ? 45.0 : 0))
        noteViewTopConstraint.isActive = true
        
        setHandler()
    }
    
    func updatePosition() {
        let noteHeight: CGFloat = frame.height - 45.0
        let position = AppDelegate.shared.position
        toolViewTopConstraint.constant = (position == 0 ? 0.0 : noteHeight)
        noteViewTopConstraint.constant = (position == 0 ? 45.0 : 0)        
    }
    
    private func setHandler() {
        toolView.historyHandler = { [om, noteView] (direction) in
            if direction {
                om.redo()
            } else {
                om.undo()
            }
            noteView?.needsDisplay = true
        }
        toolView.deleteHandler = { [om, noteView] in
            om.delete()
            noteView?.needsDisplay = true
        }
        toolView.cleanHandler = { [om, noteView] in
            om.clean()
            noteView?.needsDisplay = true
        }
        toolView.changeColorHandler = { [om, noteView] (colorID) in
            om.changeColor(colorID)
            noteView?.needsDisplay = true
        }
        toolView.changeAlphaHandler = { [om, noteView] (alpha, start) in
            om.changeAlpha(CGFloat(alpha), start)
            noteView?.needsDisplay = true
        }
        toolView.changeLineWidthHandler = { [om, noteView] (lineWidth, start) in
            om.changeLineWidth(CGFloat(lineWidth), start)
            noteView?.needsDisplay = true
        }
        toolView.copyHandler = { [om, noteView] in
            om.copySelectedObjects()
            noteView?.needsDisplay = true
        }
        toolView.arrangeHandler = { [om, noteView] (direction) in
            if direction {
                om.bringToFront()
            } else {
                om.sendToBack()
            }
            noteView?.needsDisplay = true
        }
        toolView.textDidEndEditHandler = { [om, noteView] (text) in
            om.changeText(text)
            noteView?.needsDisplay = true
        }
    }
    
    private func setMonitors() {
        monitors.append(NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown, handler: { (event) -> NSEvent? in
            self.mouseDown()
            return event
        }))
        monitors.append(NSEvent.addLocalMonitorForEvents(matching: .leftMouseDragged, handler: { (event) -> NSEvent? in
            self.mouseDragged()
            return event
        }))
        monitors.append(NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDragged, handler: { (event) in
            self.mouseDragged()
        }))
        monitors.append(NSEvent.addLocalMonitorForEvents(matching: .leftMouseUp, handler: { (event) -> NSEvent? in
            self.mouseUp()
            return event
        }))
        
        monitors.append(NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { (event) -> NSEvent? in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            let mod = ModifierFlags(flags: flags)
            if let key = Key(keyCode: event.keyCode) {
                return self.keyDown(key, mod, event)
            }
            return event
        }))
    }
    
    private func mouseDown() {
        if noteView.frame.contains(point) {
            isValid = true
            om.mouseDown(point, toolView.currentText)
            noteView.needsDisplay = true
        }
    }
    
    private func mouseDragged() {
        if isValid {
            om.mouseDragged(point)
            noteView.needsDisplay = true
        }
    }
    
    private func mouseUp() {
        if isValid {
            om.mouseUp(point)
            noteView.needsDisplay = true
        }
        isValid = false
    }
    
    private func keyDown(_ key: Key, _ mod: ModifierFlags, _ event: NSEvent?) -> NSEvent? {
        if firstResponder === toolView.textField.currentEditor() {
            if key == .escape { makeFirstResponder(nil) }
            return event
        }
        switch (key, mod) {
        case (.a, .cmd): om.allSelect(); changeType(.select)
        case (.z, .cmd):        om.undo()
        case (.z, .sftCmd):     om.redo()
        case (.delete, .empty): om.delete()
        case (.c, .empty):      om.clean()
        case (.s, .empty): changeType(.select)
        case (.p, .empty): changeType(.pen)
        case (.l, .empty): changeType(.line)
        case (.r, .empty): changeType(.fillRect)
        case (.r, .sft):   changeType(.lineRect)
        case (.o, .empty): changeType(.fillOval)
        case (.o, .sft):   changeType(.lineOval)
        case (.t, .empty): changeType(.text)
        default: break
        }
        noteView?.needsDisplay = true
        return key == .t ? nil : event
    }
    
    private func changeType(_ type: ObjectType) {
        om.changeType(type)
        toolView.updateState()
    }
    
    func fadeIn() {
        NSAnimationContext.runAnimationGroup { (context) in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            self.animator().alphaValue = 1.0
        }
    }
    
    func fadeOut() {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            self.animator().alphaValue = 0.0
        }) {
            self.close()
        }
    }
    
}
