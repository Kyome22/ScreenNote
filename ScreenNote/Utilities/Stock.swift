//
//  Stock.swift
//  ScreenNote
//
//  Created by Takuto Nakamura on 2020/05/04.
//  Copyright © 2020 Kyome. All rights reserved.
//

import Cocoa

struct Stock {
    
    var objects = [Object]()
    
    var count: Int {
        return objects.count
    }
    
    var isEmpty: Bool {
        return objects.isEmpty
    }
    
    mutating func overwrite (_ objects: [Object]) {
        self.objects = objects
    }
    
    mutating func insert(_ objects: [Object], _ at: Int) {
        self.objects.insert(contentsOf: objects, at: at)
    }
    
    mutating func append(_ object: Object) {
        objects.append(object)
    }
    
    mutating func append(_ objects: [Object]) {
        self.objects.append(contentsOf: objects)
    }
    
    mutating func remove(_ at: Int) -> Object {
        return objects.remove(at: at)
    }
    
}
