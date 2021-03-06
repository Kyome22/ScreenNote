//
//  AppDelegate.swift
//  ScreenNote
//
//  Created by Takuto Nakamura on 2017/06/18.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import Cocoa
import SpiceKey

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var menu: NSMenu!
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let dm = DataManager.shared
    private var spiceKey: SpiceKey?
    private let popover = FirstPopover()
    private var hotKeyPanel: HotKeyPanel?
    private var notePanel: NotePanel?
    private var preferencesWC: NSWindowController?
    
    var screen: NSScreen {
        let mouse = NSEvent.mouseLocation
        for screen in NSScreen.screens {
            if screen.frame.contains(mouse) {
                return screen
            }
        }
        return NSScreen.main!
    }
    
    var position: Int {
        get { return dm.position }
        set { dm.position = newValue }
    }

    class var shared: AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
    
	func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.menu = menu
        menu.delegate = self
        menu.item(at: 0)?.title = "show".localized
        statusItem.button?.image = NSImage(named: "statusIcon")
        
        setTrigger()
        #if DEBUG
        openFirstPopover()
        #endif
        #if RELEASE
        dm.ifNotYetTutorial { openFirstPopover() }
        #endif
        if dm.showToggleMethod {
            openHotKeyPanel()
        }
        setNotification()
	}

	func applicationWillTerminate(_ aNotification: Notification) {
        spiceKey?.unregister()
	}
    
    private func openFirstPopover() {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    @IBAction func openPreference(_ sender: Any?) {
		NSApp.activate(ignoringOtherApps: true)
		if preferencesWC == nil {
            let sb = NSStoryboard(name: "Preferences", bundle: nil)
			preferencesWC = (sb.instantiateInitialController() as? NSWindowController)
            preferencesWC!.window?.delegate = self
        }
        NSApp.activate(ignoringOtherApps: true)
        preferencesWC!.showWindow(nil)
	}
    
    @IBAction func openAbout(_ sender: Any?) {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }
    
    @IBAction func sendIssueReport(_ sender: Any?) {
        Mail.sendIssueReport()
    }
    
    func setNotification() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.recieveScreenEvent(_:)),
            name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }
           
    @objc func recieveScreenEvent(_ notification: NSNotification) {
        notePanel?.close()
    }
    
    private func openHotKeyPanel() {
        var rect = screen.visibleFrame
        if dm.press == 0 {
            let lRSize = CGSize(width: 380, height: 150)
            let lRLocation = CGPoint(x: 0.5 * (rect.width - lRSize.width),
                                     y: 0.5 * (rect.height - lRSize.height))
            rect = NSRect(origin: lRLocation, size: lRSize)
        } else {
            let lPSize = CGSize(width: 280, height: 150)
            let lPLocation = CGPoint(x: 0.5 * (rect.width - lPSize.width),
                                     y: 0.5 * (rect.height - lPSize.height))
            rect = NSRect(origin: lPLocation, size: lPSize)
        }
        hotKeyPanel = HotKeyPanel(frame: rect, press: dm.press, key: dm.key)
        hotKeyPanel?.delegate = self
        hotKeyPanel?.orderFrontRegardless()
    }
    
	func setTrigger() {
        var modifierFlag: ModifierFlag
        switch dm.key {
        case 0: modifierFlag = ModifierFlag.command
        case 1: modifierFlag = ModifierFlag.shift
        case 2: modifierFlag = ModifierFlag.option
        case 3: modifierFlag = ModifierFlag.control
        default: return
        }
        spiceKey?.unregister()
        if dm.press == 0 {
            spiceKey = SpiceKey(modifierFlag, bothSideModifierKeysPressHandler: { [weak self] in
                self?.showHide(nil)
            })
        } else {
            spiceKey = SpiceKey(modifierFlag, 0.5, modifierKeyLongPressHandler: { [weak self] in
                self?.showHide(nil)
            })
        }
        spiceKey?.register()
    }
    
    func setPosition() {
        if let panel = notePanel {
            panel.updatePosition()
        }
    }
    
    private func show() {
        NSApp.activate(ignoringOtherApps: true)
        menu.item(at: 0)?.title = "hide".localized
        notePanel = NotePanel(screen.visibleFrame)
        notePanel?.delegate = self
        notePanel?.orderFrontRegardless()
        notePanel?.makeKey()
        notePanel?.fadeIn()
    }

    @IBAction func showHide(_ sender: Any?) {
        if let panel = notePanel {
            menu.item(at: 0)?.title = "show".localized
            panel.fadeOut()
        } else {
            if hotKeyPanel != nil {
                hotKeyPanel?.fadeOut {
                    self.show()
                }
            } else {
                show()
            }
        }
    }
    
}

extension AppDelegate: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        if window === hotKeyPanel {
            hotKeyPanel = nil
        } else if window === notePanel {
            notePanel = nil
        } else if window === preferencesWC?.window {
            preferencesWC = nil
        }
    }
    
}

extension AppDelegate: NSMenuDelegate {
    
    func menuWillOpen(_ menu: NSMenu) {
        if popover.isShown {
            popover.performClose(nil)
        }
    }
    
}
