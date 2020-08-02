//
//  ObjectManager.swift
//  ScreenNote
//
//  Created by Takuto Nakamura on 2019/06/09.
//  Copyright © 2019 Kyome. All rights reserved.
//

import Cocoa

enum Action {
    case none
    case move
    case resize
}

final class ObjectManager {
    
    static let shared = ObjectManager()
    
    private let um = UndoManager()
    private var stocks = [Stock]()
    private var currentHistry: Int = -1
    private var lastPoint: CGPoint?
    private var action: Action = .none
    private var anchor: Anchor = .topLeft
    private(set) var selectObject: Object?
    private(set) var currentType: ObjectType = .pen
    private(set) var currentColorID: Int = 0
    private(set) var currentAlpha: CGFloat = 0.7
    private(set) var currentLineWidth: CGFloat = 4.0
    
    let colors: [NSColor] = [
        .uniqueRed,
        .uniqueOrange,
        .uniqueYello,
        .uniqueGreen,
        .uniqueBlue,
        .uniqueViolet,
        .uniquePurple,
        .white,
        .black,
    ]
    
    var objects: [Object] {
        if currentHistry < 0 { return [] }
        return stocks[currentHistry].objects
    }
    var beforeObjects: [Object] {
        if currentHistry < 1 { return [] }
        return stocks[currentHistry - 1].objects
    }
    var isSelected: Bool {
        return objects.firstIndex(where: { (object) -> Bool in
            return object.isSelected
        }) != nil
    }
    var selectedObjects: [Object] {
        return objects.filter { (object) -> Bool in
            return object.isSelected
        }
    }
    func selectedBounds(_ objects: [Object]) -> CGRect? {
        var bounds: CGRect? = nil
        for object in objects {
            bounds = (bounds == nil ? object.bounds : bounds!.union(object.bounds))
        }
        return bounds
    }
    
    private init() {
        addStock()
    }
    
    deinit {
        stocks.removeAll()
    }
    
    func hitAnchor(_ point: CGPoint) -> Int {
        guard let bounds = selectedBounds(selectedObjects) else { return -1 }
        let paths = NSBezierPath.anchorPaths(bounds: bounds)
        return paths.firstIndex(where: { (path) -> Bool in path.contains(point) }) ?? -1
    }
    
    func move(_ obs: inout [Object], _ gap: CGPoint) {
        for i in (0 ..< obs.count) {
            if obs[i].isSelected {
                for j in (0 ..< obs[i].points.count) {
                    obs[i].points[j] += gap
                }
            }
        }
    }
    
    func resize(_ obs: inout [Object], _ gap: CGPoint) {
        let beforeSelectedObjects = obs.filter { (object) -> Bool in
            return object.isSelected
        }
        guard let oldBounds = selectedBounds(beforeSelectedObjects)  else { return }
        var newBounds = ResizeRect(oldBounds)
        switch anchor {
        case .topLeft:
            newBounds.origin.x += gap.x
            newBounds.size.width -= gap.x
            newBounds.size.height += gap.y
        case .top:
            newBounds.size.height += gap.y
        case .topRight:
            newBounds.size.width += gap.x
            newBounds.size.height += gap.y
        case .right:
            newBounds.size.width += gap.x
        case .bottomRight:
            newBounds.origin.y += gap.y
            newBounds.size.width += gap.x
            newBounds.size.height -= gap.y
        case .bottom:
            newBounds.origin.y += gap.y
            newBounds.size.height -= gap.y
        case .bottomLeft:
            newBounds.origin.x += gap.x
            newBounds.origin.y += gap.y
            newBounds.size.width -= gap.x
            newBounds.size.height -= gap.y
        case .left:
            newBounds.origin.x += gap.x
            newBounds.size.width -= gap.x
        }
        let translationTF1 = CGAffineTransform(translationX: -oldBounds.origin.x,
                                               y: -oldBounds.origin.y)
        let scaleTF = CGAffineTransform(scaleX: newBounds.width / oldBounds.width,
                                        y: newBounds.height / oldBounds.height)
        let translationTF2 = CGAffineTransform(translationX: newBounds.origin.x,
                                               y: newBounds.origin.y)
        if beforeSelectedObjects.count == 1 && oldBounds.size == CGSize.zero {
            for i in (0 ..< obs.count) {
                if obs[i].isSelected {
                    obs[i].points[0] += gap
                    return
                }
            }
        }
        for i in (0 ..< obs.count) {
            if obs[i].isSelected {
                for j in (0 ..< obs[i].points.count) {
                    var p = obs[i].points[j]
                    p = p.applying(translationTF1)
                    p = p.applying(scaleTF)
                    obs[i].points[j] = p.applying(translationTF2)
                }
            }
        }
    }
    
    // MARK: Mouse Event
    func mouseDown(_ point: CGPoint, _ text: String) {
        switch currentType {
        case .select:
            var obs = objects
            if let a = Anchor(rawValue: hitAnchor(point)) {
                lastPoint = point
                action = .resize
                anchor = a
                addStock()
            } else if !selectedObjects.filter({ (object) -> Bool in return object.isHit(point) }).isEmpty {
                lastPoint = point
                action = .move
                addStock()
            } else if let index = obs.lastIndex(where: { (object) -> Bool in return object.isHit(point) }) {
                lastPoint = point
                action = .move
                addStock()
                for i in (0 ..< obs.count) {
                    obs[i].isSelected = false
                }
                obs[index].isSelected = true
                overwrite(obs)
                addStock()
            } else {
                addStock()
                selectObject = Object(.select, 8, 1.0, 1.0, [point, point])
                for i in (0 ..< obs.count) {
                    obs[i].isSelected = false
                }
                overwrite(obs)
            }
        case .pen:
            addStock()
            var obs = objects
            obs.append(Object(currentType, currentColorID, currentAlpha, currentLineWidth, [point]))
            overwrite(obs)
        default:
            addStock()
            var obs = objects
            var obj = Object(currentType, currentColorID, currentAlpha, currentLineWidth, [point, point])
            if currentType == .text { obj.text = text }
            obs.append(obj)
            overwrite(obs)
        }
    }
    
    func mouseDragged(_ point: CGPoint) {
        switch currentType {
        case .select:
            if selectObject != nil {
                selectObject!.points[1] = point
            }
            if lastPoint != nil {
                let gap: CGPoint = point - lastPoint!
                var obs = beforeObjects
                switch action {
                case .move: move(&obs, gap)
                case .resize: resize(&obs, gap)
                default: break
                }
                overwrite(obs)
            }
        case .pen:
            var obs = objects
            obs[obs.count - 1].points.append(point)
            overwrite(obs)
        default:
            var obs = objects
            obs[obs.count - 1].points[1] = point
            overwrite(obs)
        }
    }
    
    func mouseUp(_ point: CGPoint) {
        switch currentType {
        case .select:
            if selectObject != nil, selectObject!.bounds.size != .zero {
                var obs = objects
                for i in (0 ..< obs.count) {
                    if obs[i].isHit(selectObject!.bounds) {
                        obs[i].isSelected = true
                    }
                }
                overwrite(obs)
            }
            lastPoint = nil
            action = .none
            selectObject = nil
        case .pen:
            break
        default:
            var obs = objects
            if obs[obs.count - 1].points[0].length(from: point) < 5 {
                obs.removeLast()
            }
            overwrite(obs)
        }
    }
    
    // MARK: Control
    func changeType(_ type: ObjectType) {
        currentType = type
        if type == .select { return }
        var obs = objects
        for i in (0 ..< obs.count) {
            obs[i].isSelected = false
        }
        overwrite(obs)
    }

    func changeText(_ text: String) {
        if currentType == .select {
            addStock()
            var obs = objects
            for i in (0 ..< obs.count) {
                if obs[i].isSelected && obs[i].type == .text {
                    obs[i].text = text
                }
            }
            overwrite(obs)
        }
    }
    
    func changeColor(_ colorID: Int) {
        currentColorID = colorID
        if currentType == .select && isSelected {
            addStock()
            var obs = objects
            for i in (0 ..< obs.count) {
                if obs[i].isSelected {
                    obs[i].colorID = currentColorID
                }
            }
            overwrite(obs)
        }
    }
    
    func changeAlpha(_ alpha: CGFloat, _ start: Bool) {
        currentAlpha = alpha
        if currentType == .select && isSelected {
            if start { addStock() }
            var obs = objects
            for i in (0 ..< obs.count) {
                if obs[i].isSelected {
                    obs[i].alpha = currentAlpha
                }
            }
            overwrite(obs)
        }
    }
    
    func changeLineWidth(_ lineWidth: CGFloat, _ start: Bool) {
        currentLineWidth = lineWidth
        if currentType == .select && isSelected {
            if start { addStock() }
            var obs = objects
            for i in (0 ..< obs.count) {
                if obs[i].isSelected {
                    obs[i].lineWidth = currentLineWidth
                }
            }
            overwrite(obs)
        }
    }
    
    func delete() {
        if isSelected {
            addStock()
            var obs = objects
            obs.removeAll { (object) -> Bool in
                return object.isSelected
            }
            overwrite(obs)
        }
    }
    
    func clean() {
        if objects.isEmpty { return }
        addStock()
        overwrite([])
    }
    
    func allSelect() {
        if objects.isEmpty { return }
        if selectedObjects.count == objects.count { return }
        addStock()
        var obs = objects
        for i in (0 ..< obs.count) {
            obs[i].isSelected = true
        }
        overwrite(obs)
    }
    
    func bringToFront() {
        let sObs = selectedObjects
        if sObs.isEmpty { return }
        addStock()
        var obs = objects
        obs.removeAll { (object) -> Bool in
            return object.isSelected
        }
        obs.append(contentsOf: sObs)
        overwrite(obs)
    }
    
    func sendToBack() {
        let sObs = selectedObjects
        if sObs.isEmpty { return }
        addStock()
        var obs = objects
        obs.removeAll { (object) -> Bool in
            return object.isSelected
        }
        obs.insert(contentsOf: sObs, at: 0)
        overwrite(obs)
    }
    
    // MARK: History
    func addStock() {
        if stocks.isEmpty {
            stocks.append(Stock())
        } else {
            stocks.removeSubrange(currentHistry + 1 ..< stocks.count)
            if currentHistry < 0 {
                stocks.append(Stock())
            } else if currentHistry < 15 {
                stocks.append(stocks[currentHistry])
            } else {
                stocks.append(stocks[currentHistry])
                stocks.removeFirst()
                currentHistry -= 1
            }
        }
        currentHistry += 1
        um.registerUndo(withTarget: self) { [weak self] _ in
            self?.prevStock()
        }
    }
    
    private func nextStock() {
        if currentHistry < stocks.count - 1 {
            currentHistry += 1
            um.registerUndo(withTarget: self) { [weak self] _ in
                self?.prevStock()
            }
        }
    }
    
    private func prevStock() {
        if 0 < currentHistry {
            currentHistry -= 1
            um.registerUndo(withTarget: self) { [weak self] _ in
                self?.nextStock()
            }
        }
    }
    
    private func overwrite(_ objects: [Object]) {
        if currentHistry < 0 { return }
        stocks[currentHistry].objects = objects
    }
    
    func undo() {
        um.undo()
    }
    
    func redo() {
        um.redo()
    }
    
}
