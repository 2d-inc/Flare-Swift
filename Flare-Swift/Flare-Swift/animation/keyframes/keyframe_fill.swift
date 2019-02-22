//
//  keyframe_fill.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/18/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class KeyFrameFillColor: Interpolated {
    var _interpolator: Interpolator?
    
    var _time: Double = 0.0
    
    private var _value = [Float32].init(repeating: 0, count: 4)
    
    func applyInterpolation(component: ActorComponent, time: Double, toFrame: KeyFrame, mix: Double) {
        let ac = component as! ActorColor
        let to = (toFrame as! KeyFrameFillColor)._value
        let l = _value.count
        
        let fmix = Float32(mix)
        let f: Float32 = Float32((time - _time) / (toFrame._time - _time))
        let fi: Float32 = 1.0 - f
        if fmix == 1.0 {
            for i in 0 ..< l {
                ac.color[i] = _value[i] * fi + to[i] * f
            }
        } else {
            let mixi = 1.0 - fmix
            for i in 0 ..< l {
                let v = _value[i] * fi + to[i] * f
                ac.color[i] = ac.color[i] * mixi + v * fmix
            }
        }
        
        ac.markPaintDirty()
    }
    
    func apply(component: ActorComponent, mix: Double) {
        let ac = component as! ActorColor
        let l = _value.count
        let fmix = Float32(mix)
        
        if fmix == 1.0 {
            for i in 0 ..< l {
                ac.color[i] = _value[i];
            }
        } else {
            let mixi: Float32 = 1.0 - fmix;
            for i in 0 ..< l {
                ac.color[i] = ac.color[i] * mixi + _value[i] * fmix;
            }
        }
        ac.markPaintDirty();
    }
    
    func setNext(_ frame: KeyFrame) {
        // Do nothing.
    }
    
    func read(_ reader: StreamReader) -> Bool {
        if !readInterpolation(reader) {
            return false
        }
        reader.readFloat32ArrayOffset(ar: &_value, length: 4, offset: 0, label: "value")
        return true
    }
    
    
}
