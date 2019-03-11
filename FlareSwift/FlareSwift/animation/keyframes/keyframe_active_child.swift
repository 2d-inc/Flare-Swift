//
//  keyframe_active_child.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class KeyFrameActiveChild: KeyFrame {
    var _time: Double = 0.0
    var _value: Int = -1
    
    func applyInterpolation(component: ActorComponent, time: Double, toFrame: KeyFrame, mix: Float) {
        self.apply(component: component, mix: mix)
    }
    
    func apply(component: ActorComponent, mix: Float) {
        let solo = component as! ActorNodeSolo
        solo.activeChildIndex = _value
    }
    
    func setNext(_ frame: KeyFrame) {
        // Do nothing.
    }
    
    func read(_ reader: StreamReader) -> Bool {
        if !self.readTime(reader) {
            return false
        }
        self._value = Int(reader.readFloat32(label: "value"))
        return true
    }
    
}
