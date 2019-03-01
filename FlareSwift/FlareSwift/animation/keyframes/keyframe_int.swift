//
//  keyframe_int.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/18/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class KeyFrameInt: Interpolated {
    var _time: Double
    
    var _interpolator: Interpolator?
    
    var _value: Double
    var value: Double {
        return _value
    }
    
    init() {
        self._time = 0
        self._value = 0
    }
    
    func applyInterpolation(component: ActorComponent, time: Double, toFrame: KeyFrame, mix: Double) {
        let to = toFrame as! KeyFrameInt
        var f = (time - self._time) / (to._time - self._time)
        if let interpolator = self._interpolator {
            f = interpolator.getEasedMix(mix: f)
        }
        setValue(component, _value * (1.0 - f) + to._value * f, mix)
    }
    
    func apply(component: ActorComponent, mix: Double) {
        setValue(component, _value, mix)
    }
    
    func setNext(_ frame: KeyFrame) {}
    
    func read(_ reader: StreamReader) -> Bool {
        if !self.readInterpolation(reader) {
            return false
        }
        self._value = Double(reader.readInt32(label: "value"))
        return true
    }
    
    func setValue(_ component: ActorComponent, _ value: Double, _ mix: Double) {
        preconditionFailure("KeyFrameInt::setValue()")
    }
}
