//
//  ToolView.swift
//  ScreenNote
//
//  Created by Takuto Nakamura on 2019/06/08.
//  Copyright © 2019 Kyome. All rights reserved.
//

import Cocoa

class ToolView: NSView {

    @IBOutlet weak var hideButton: NSButton!
    @IBOutlet weak var prevButton: NSButton!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var cleanButton: NSButton!
    @IBOutlet weak var selectButton: NSButton!
    @IBOutlet weak var penButton: NSButton!
    @IBOutlet weak var lineButton: NSButton!
    @IBOutlet weak var fillRectButton: NSButton!
    @IBOutlet weak var lineRectButton: NSButton!
    @IBOutlet weak var fillOvalButton: NSButton!
    @IBOutlet weak var lineOvalButton: NSButton!
    @IBOutlet weak var TextButton: NSButton!
    @IBOutlet weak var colorPopUp: NSPopUpButton!
    @IBOutlet weak var alphaSlider: NSSlider!
    @IBOutlet weak var lineWidthSlider: NSSlider!
    @IBOutlet weak var bringFrontButton: NSButton!
    @IBOutlet weak var sendBackButton: NSButton!
    
    private var w: CGFloat { return self.frame.width  }
    private var h: CGFloat { return self.frame.height }
    private let om = ObjectManager.shared
    
    var historyHandler: ((_ direction: Bool) -> Void)?
    var deleteHandler: (() -> Void)?
    var cleanHandler: (() -> Void)?
    var changeColorHandler: ((_ colorID: Int) -> Void)?
    var changeAlphaHandler: ((_ alpha: Float, _ start: Bool) -> Void)?
    var changeLineWidthHandler: ((_ lineWidth: Float, _ start: Bool) -> Void)?
    var arrangeHandler: ((_ direction: Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let isDark = self.effectiveAppearance.isDark
        self.wantsLayer = true
        self.layer?.backgroundColor = isDark ? CGColor.darkToolBG : CGColor.lightToolBG
        initialize(button: &hideButton, toolTip: "hide".localized, isDark)
        initialize(button: &prevButton, toolTip: "prev".localized, isDark)
        initialize(button: &nextButton, toolTip: "next".localized, isDark)
        initialize(button: &deleteButton, toolTip: "delete".localized, isDark)
        initialize(button: &cleanButton, toolTip: "clean".localized, isDark)
        initialize(button: &selectButton, toolTip: "select".localized, isDark)
        initialize(button: &penButton, toolTip: "pen".localized, isDark)
        initialize(button: &lineButton, toolTip: "line".localized, isDark)
        initialize(button: &fillRectButton, toolTip: "fillRect".localized, isDark)
        initialize(button: &lineRectButton, toolTip: "lineRect".localized, isDark)
        initialize(button: &fillOvalButton, toolTip: "fillOval".localized, isDark)
        initialize(button: &lineOvalButton, toolTip: "lineOval".localized, isDark)
        initialize(button: &TextButton, toolTip: "text".localized, isDark)
        updateState()
        initializeColorPopUp(isDark)
        alphaSlider.toolTip = "alpha".localized
        alphaSlider.floatValue = Float(om.currentAlpha)
        lineWidthSlider.toolTip = "lineWidth".localized
        lineWidthSlider.floatValue = Float(om.currentLineWidth)
        initialize(button: &bringFrontButton, toolTip: "bringFront".localized, isDark)
        initialize(button: &sendBackButton, toolTip: "sendBack".localized, isDark)
    }
    
    private func initialize(button: inout NSButton, toolTip: String, _ isDark: Bool) {
        button.wantsLayer = true
        button.layer?.backgroundColor = isDark ? CGColor.darkButton : CGColor.lightButton
        button.layer?.cornerRadius = 5.0
        button.toolTip = toolTip
    }
    
    func updateState() {
        let type = om.currentType
        selectButton.state = (type == .select ? .on : .off)
        penButton.state = (type == .pen ? .on : .off)
        lineButton.state = (type == .line ? .on : .off)
        fillRectButton.state = (type == .fillRect ? .on : .off)
        lineRectButton.state = (type == .lineRect ? .on : .off)
        fillOvalButton.state = (type == .fillOval ? .on : .off)
        lineOvalButton.state = (type == .lineOval ? .on : .off)
    }
    
    private func initializeColorPopUp(_ isDark: Bool) {
        let colors = om.colors
        colorPopUp.wantsLayer = true
        colorPopUp.layer?.backgroundColor = isDark ? CGColor.darkButton : CGColor.lightButton
        colorPopUp.layer?.cornerRadius = 5.0
        colorPopUp.toolTip = "colorPopUp".localized
        colorPopUp.removeAllItems()
        colorPopUp.addItems(withTitles: colors.map({ (c) -> String in return "" }))
        for (i, item) in colorPopUp.itemArray.enumerated() {
            item.image = colors[i].swatch
        }
        colorPopUp.selectItem(at: om.currentColorID)
    }
    
    @IBAction func pushHide(_ sender: Any) {
        AppDelegate.shared.showHide(sender)
    }
    
    @IBAction func pushPrev(_ sender: Any) {
        historyHandler?(false)
    }
    
    @IBAction func pushNext(_ sender: Any) {
        historyHandler?(true)
    }
    
    @IBAction func pushDelete(_ sender: Any) {
        deleteHandler?()
    }
    
    @IBAction func pushClean(_ sender: Any) {
        cleanHandler?()
    }
    
    @IBAction func pushSelectTool(_ sender: Any) {
        om.changeType(.select)
        updateState()
    }
    
    @IBAction func pushPenTool(_ sender: Any) {
        om.changeType(.pen)
        updateState()
    }
    
    @IBAction func pushLineTool(_ sender: Any) {
        om.changeType(.line)
        updateState()
    }
    
    @IBAction func pushFillRectTool(_ sender: Any) {
        om.changeType(.fillRect)
        updateState()
    }
    
    @IBAction func pushLineRectTool(_ sender: Any) {
        om.changeType(.lineRect)
        updateState()
    }
    
    @IBAction func pushFillOvalTool(_ sender: Any) {
        om.changeType(.fillOval)
        updateState()
    }
    
    @IBAction func pushLineOvalTool(_ sender: Any) {
        om.changeType(.lineOval)
        updateState()
    }

    @IBAction func pushTextTool(_ sender: Any) {
        om.changeType(.text)
        updateState()
    }
    
    @IBAction func changeColor(_ sender: NSPopUpButton) {
        changeColorHandler?(sender.indexOfSelectedItem)
    }
    
    @IBAction func changeAlpha(_ sender: NSSlider) {
        let event = NSApp.currentEvent
        let start: Bool = (event?.type == NSEvent.EventType.leftMouseDown)
        changeAlphaHandler?(sender.floatValue, start)
    }
    
    @IBAction func changeLineWidth(_ sender: NSSlider) {
        let event = NSApp.currentEvent
        let start: Bool = (event?.type == NSEvent.EventType.leftMouseDown)
        changeLineWidthHandler?(sender.floatValue, start)
    }
    
    @IBAction func pushBringFront(_ sender: Any) {
        arrangeHandler?(true)
    }
    
    @IBAction func pushSendBack(_ sender: Any) {
        arrangeHandler?(false)
    }
    
}
