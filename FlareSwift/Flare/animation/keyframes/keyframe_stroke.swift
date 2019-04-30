//
//  keyframe_stroke.swift
//  Flare
//
//  Created by Umberto Sonnino on 2/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class KeyFrameStrokeColor: Interpolated {
    private var _value: [Float] = []
    var _interpolator: Interpolator?
    var _time: Double = 0.0
    
    var value: [Float] {
        return _value
    }
    
    func applyInterpolation(component: ActorComponent, time: Double, toFrame: KeyFrame, mix: Float) {
        let cs = component as! ColorStroke
        let to = (toFrame as! KeyFrameStrokeColor)
        let len = _value.count
        
        let fMix: Float = Float(mix)
        let f = Float((time - _time) / (toFrame._time - _time))
        let fi = 1.0 - f
        if fMix == 1.0 {
            for i in 0 ..< len {
                cs.color[i] = _value[i] * fi + to._value[i] * f;
            }
        } else {
            let mixi = 1.0 - fMix
            for i in 0 ..< len {
                let v = _value[i] * fi + to._value[i] * f;
                
                cs.color[i] = cs.color[i] * mixi + v * fMix
            }
        }
        cs.markPaintDirty();
    }
    
    func apply(component: ActorComponent, mix: Float) {
        let node = component as! ColorStroke
        let len = node.color.count
        let fMix: Float = Float(mix)
        
        if fMix == 1.0 {
            for i in 0 ..< len {
                node.color[i] = _value[i];
            }
        } else {
            let mixi = 1.0 - fMix;
            for i in 0 ..< len {
                node.color[i] = node.color[i] * mixi + _value[i] * fMix;
            }
        }
        node.markPaintDirty();
    }
    
    func setNext(_ frame: KeyFrame) {
        // Do nothing.
    }
    
    func read(_ reader: StreamReader) -> Bool {
        if !self.readInterpolation(reader) {
            return false
        }
        self._value = Array.init(repeating: 0.0, count: 4)
        reader.readFloat32ArrayOffset(ar: &self._value, length: 4, offset: 0, label: "value")
        return true
    }
}

class KeyFrameStrokeWidth: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Float, _ mix: Float) {
        let stroke = component as! ActorStroke
        stroke.width = stroke.width * (1.0 - mix) + value * mix
    }
}

class KeyFrameStrokeStart: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Float, _ mix: Float) {
        let stroke = component as! ActorStroke
        stroke.trimStart = stroke.trimStart * (1.0 - mix) + value * mix
    }
}

class KeyFrameStrokeEnd: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Float, _ mix: Float) {
        let stroke = component as! ActorStroke
        stroke.trimEnd = stroke.trimEnd * (1.0 - mix) + value * mix
    }
}

class KeyFrameStrokeOffset: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Float, _ mix: Float) {
        let stroke = component as! ActorStroke
        stroke.trimOffset = stroke.trimOffset * (1.0 - mix) + value * mix
    }
}
