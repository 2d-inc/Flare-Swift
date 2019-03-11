//
//  keyframe_draworder.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/18/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

struct DrawOrderIndex {
    var componentIndex: Int
    var order: Int
}

class KeyFrameDrawOrder: KeyFrame {
    var _time: Double = 0.0
    
    var _orderedNodes: [DrawOrderIndex]?
    
    func read(_ reader: StreamReader) -> Bool {
        if !self.readTime(reader) {
            return false
        }
        
        reader.openArray(label: "drawOrder")
        let numOrderedNodes = Int(reader.readUint16Length())
        _orderedNodes = [DrawOrderIndex]()
        for i in 0 ..< numOrderedNodes {
            reader.openObject(label: "order")
            let drawOrder = DrawOrderIndex(
                componentIndex: reader.readId(label: "component"),
                order: Int(reader.readUint16(label: "order"))
            )
            reader.closeObject()
            _orderedNodes?.insert(drawOrder, at: i)

        }
        reader.closeArray()
        return true
    }
    
    func applyInterpolation(component: ActorComponent, time: Double, toFrame: KeyFrame, mix: Float) {
        apply(component: component, mix: mix)
    }
    
    func apply(component: ActorComponent, mix: Float) {
        guard let artboard = component.artboard else {
            fatalError("NO ARTBOARD FOR COMPONENT??")
        }
        
        for doi in _orderedNodes! {
            if var drawable = artboard[doi.componentIndex] as? ActorDrawable {
                drawable.drawOrder = doi.order
            } else {
                fatalError("Not a drawable?? \(artboard[doi.componentIndex]?.name ?? "UNKNOWN COMPONENT")")
            }
        }
        
    }
    
    func setNext(_ frame: KeyFrame) {
        // Do nothing.
    }
    
}
