/*
  MenuBar.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import AppKit
import Combine

final class MenuBar: NSObject {
    private let statusItem = NSStatusItem.default
    private let menu = NSMenu()
    private let showCanvasMenuItem = NSMenuItem()
    private let hideCanvasMenuItem = NSMenuItem()
    private let menuBarModel: MenuBarModel
    private var cancellables = Set<AnyCancellable>()

    init(menuBarModel: MenuBarModel) {
        self.menuBarModel = menuBarModel
        super.init()

        showCanvasMenuItem.setValues(title: "showCanvas".localized,
                                     action: #selector(showCanvas(_:)),
                                     target: self)
        menu.addItem(showCanvasMenuItem)
        hideCanvasMenuItem.setValues(title: "hideCanvas".localized,
                                     action: #selector(hideCanvas(_:)),
                                     target: self)
        hideCanvasMenuItem.isHidden = true
        menu.addItem(hideCanvasMenuItem)
        menu.addSeparator()
        menu.addItem(title: "settings".localized,
                     action: #selector(openSettings(_:)),
                     target: self)
        menu.addSeparator()
        menu.addItem(title: "aboutApp".localized,
                     action: #selector(openAbout(_:)),
                     target: self)
        menu.addItem(title: "reportAnIssue".localized,
                     action: #selector(sendIssueReport(_:)),
                     target: self)
        menu.addItem(title: "terminateApp".localized,
                     action: #selector(terminateApp(_:)),
                     target: self)

        statusItem.menu = menu
        statusItem.button?.image = NSImage(named: "StatusIcon")

        menuBarModel.showOrHideCanvasPublisher
            .sink { [weak self] flag in
                self?.showCanvasMenuItem.isHidden = flag
                self?.hideCanvasMenuItem.isHidden = !flag
            }
            .store(in: &cancellables)
    }

    @objc func showCanvas(_ sender: NSMenuItem) {
        menuBarModel.toggleCanvasVisible(true)
        sender.isHidden = true
        hideCanvasMenuItem.isHidden = false
    }

    @objc func hideCanvas(_ sender: NSMenuItem) {
        menuBarModel.toggleCanvasVisible(false)
        sender.isHidden = true
        showCanvasMenuItem.isHidden = false
    }

    @objc func openSettings(_ sender: Any?) {
        menuBarModel.openSettings()
    }

    @objc func openAbout(_ sender: Any?) {
        menuBarModel.openAbout()
    }

    @objc func sendIssueReport(_ sender: Any?) {
        menuBarModel.sendIssueReport()
    }

    @objc func terminateApp(_ sender: Any?) {
        menuBarModel.terminateApp()
    }
}
