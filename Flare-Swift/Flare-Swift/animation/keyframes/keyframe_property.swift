//
//  keyframe_property.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/18/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation


class KeyFrameIntProperty : KeyFrameInt {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Double, _ mix: Double) {
        // TODO:
        //var node = component as CustomIntProperty;
        //node.value = (node.value * (1.0 - mix) + value * mix).round();
    }
}

class KeyFrameFloatProperty: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Double, _ mix: Double) {
        // TODO:
        //var node = component as CustomIntProperty;
        //node.value = (node.value * (1.0 - mix) + value * mix).round();
    }
}

class KeyFrameStringProperty: KeyFrame {
    var _time: Double = 0.0
    var _value: String = ""
    
    func applyInterpolation(component: ActorComponent, time: Double, toFrame: KeyFrame, mix: Double) {
        apply(component: component, mix: mix)
    }
    
    func apply(component: ActorComponent, mix: Double) {
        // var prop = component as CustomStringProperty;
        // prop.value = _value;
    }
    
    func setNext(_ frame: KeyFrame) {
        // Do Nothing
    }
    
    func read(_ reader: StreamReader) -> Bool {
        if !self.readTime(reader) {
            return false
        }
        self._value = reader.readString(label: "value")
        return true
    }
    
}

class KeyFrameBooleanProperty: KeyFrame {
    var _time: Double = 0.0
    var _value: Bool = false
    
    func applyInterpolation(component: ActorComponent, time: Double, toFrame: KeyFrame, mix: Double) {
        apply(component: component, mix: mix)
    }
    
    func apply(component: ActorComponent, mix: Double) {
        // var prop = component as CustomBooleanProperty;
        // prop.value = _value;
    }
    
    func setNext(_ frame: KeyFrame) {
        // Do Nothing
    }
    
    func read(_ reader: StreamReader) -> Bool {
        if !self.readTime(reader) {
            return false
        }
        self._value = reader.readBool(label: "value")
        return true
    }
}

class KeyFrameCollisionEnabledProperty: KeyFrame {
    var _time: Double = 0.0
    var _value: Bool = false
    
    func applyInterpolation(component: ActorComponent, time: Double, toFrame: KeyFrame, mix: Double) {
        apply(component: component, mix: mix)
    }
    
    func apply(component: ActorComponent, mix: Double) {
        // var prop = component as CustomBooleanProperty;
        // prop.value = _value;
    }
    
    func setNext(_ frame: KeyFrame) {
        // Do Nothing
    }
    
    func read(_ reader: StreamReader) -> Bool {
        if !self.readTime(reader) {
            return false
        }
        self._value = reader.readBool(label: "value")
        return true
    }
}
