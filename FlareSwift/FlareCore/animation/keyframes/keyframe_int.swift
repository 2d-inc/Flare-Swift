//
//  keyframe_int.swift
//  FlareCore
//
//  Created by Umberto Sonnino on 2/18/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class KeyFrameInt: Interpolated {
    var _time: Double
    
    var _interpolator: Interpolator?
    
    var _value: Float
    var value: Float {
        return _value
    }
    
    init() {
        self._time = 0
        self._value = 0
    }
    
    func applyInterpolation(component: ActorComponent, time: Double, toFrame: KeyFrame, mix: Float) {
        let to = toFrame as! KeyFrameInt
        var f = Float((time - self._time) / (to._time - self._time))
        if let interpolator = self._interpolator {
            f = interpolator.getEasedMix(mix: f)
        }
        setValue(component, _value * (1.0 - f) + to._value * f, mix)
    }
    
    func apply(component: ActorComponent, mix: Float) {
        setValue(component, _value, mix)
    }
    
    func setNext(_ frame: KeyFrame) {}
    
    func read(_ reader: StreamReader) -> Bool {
        if !self.readInterpolation(reader) {
            return false
        }
        self._value = Float(reader.readInt32(label: "value"))
        return true
    }
    
    func setValue(_ component: ActorComponent, _ value: Float, _ mix: Float) {
        preconditionFailure("KeyFrameInt::setValue()")
    }
}
