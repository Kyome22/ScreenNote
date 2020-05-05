//
//  DataManager.swift
//  ScreenNote
//
//  Created by Takuto Nakamura on 2020/05/02.
//  Copyright © 2020 Kyome. All rights reserved.
//

import Foundation

let RESET_DATA: Bool = false

class DataManager {
    
    static let shared = DataManager()
    
    private let userDefaults = UserDefaults.standard
    
    var tutorial: Bool {
        get { return userDefaults.bool(forKey: "tutorial") }
        set { userDefaults.set(newValue, forKey: "tutorial") }
    }
    var press: Int {
        get { return userDefaults.integer(forKey: "press") }
        set { userDefaults.set(newValue, forKey: "press") }
    }
    var key: Int {
        get { return userDefaults.integer(forKey: "key") }
        set { userDefaults.set(newValue, forKey: "key") }
    }
    var position: Int {
        get { return userDefaults.integer(forKey: "position") }
        set { userDefaults.set(newValue, forKey: "position") }
    }

    private init() {
        #if DEBUG
        if RESET_DATA {
            userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }
        #endif
        userDefaults.register(defaults: ["press" : Int(0),
                                         "key" : Int(0),
                                         "position" : Int(0)])
    }
    
    func ifNotYetTutorial(_ callback: () -> Void) {
        if !tutorial {
            tutorial = true
            callback()
        }
    }
    
}
