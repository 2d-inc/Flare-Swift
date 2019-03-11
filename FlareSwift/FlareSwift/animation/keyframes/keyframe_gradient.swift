//
//  keyframe_gradient.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class KeyFrameGradient: Interpolated {
    private var _value = [Float32]()
    var _interpolator: Interpolator?
    var _time: Double = 0.0
    
    var value: [Float32] {
        return _value
    }
    
    func applyInterpolation(component: ActorComponent, time: Double, toFrame: KeyFrame, mix: Float) {
        let gradient = component as! GradientColor
        let kfg = (toFrame as! KeyFrameGradient)
        
        var f = Float((time - _time) / (toFrame._time - _time))
        if let interpolator = _interpolator {
            f = interpolator.getEasedMix(mix: f)
        }
        
        let ff = Float32(f)
        let fi = 1.0 - ff
        
        var ridx = 0;
        var wi = 0;
        
        if (mix == 1.0) {
            gradient.start[0] = _value[ridx] * fi + kfg._value[ridx] * ff
            ridx += 1
            gradient.start[1] = _value[ridx] * fi + kfg._value[ridx] * ff
            ridx += 1
            gradient.end[0] = _value[ridx] * fi + kfg._value[ridx] * ff
            ridx += 1
            gradient.end[1] = _value[ridx] * fi + kfg._value[ridx] * ff
            ridx += 1
            
            while ridx < kfg._value.count && wi < gradient.colorStops.count {
                gradient.colorStops[wi] = _value[ridx] * fi + kfg._value[ridx] * ff
                wi += 1
                ridx += 1
            }
        } else {
            let imix = 1.0 - mix
            
            // Mix : first interpolate the KeyFrames, and then mix on top of the current value.
            var val = _value[ridx] * fi + kfg._value[ridx] * ff
            gradient.start[0] = gradient.start[0] * imix + val * mix
            ridx += 1
            
            val = _value[ridx] * fi + kfg._value[ridx] * ff
            gradient.start[1] = gradient.start[1] * imix + val * mix
            ridx += 1
            
            val = _value[ridx] * fi + kfg._value[ridx] * ff
            gradient.end[0] = gradient.end[0] * imix + val * mix
            ridx += 1
            
            val = _value[ridx] * fi + kfg._value[ridx] * ff
            gradient.end[1] = gradient.end[1] * imix + val * mix
            ridx += 1
            
            while ridx < kfg._value.count && wi < gradient.colorStops.count {
                val = _value[ridx] * fi + kfg._value[ridx] * ff
                gradient.colorStops[wi] = gradient.colorStops[wi] * imix + val * mix
                
                    ridx += 1
                wi += 1
            }
        }
        gradient.markPaintDirty()
    }
    
    func apply(component: ActorComponent, mix: Float) {
        let gradient = component as! GradientColor
        
        var ridx = 0
        var wi = 0
        
        if mix == 1.0 {
            gradient.start[0] = _value[ridx]
            ridx += 1
            gradient.start[1] = _value[ridx]
            ridx += 1
            gradient.end[0] = _value[ridx]
            ridx += 1
            gradient.end[1] = _value[ridx]
            ridx += 1
            
            while ridx < _value.count && wi < gradient.colorStops.count {
                gradient.colorStops[wi] = _value[ridx]
                wi += 1
                ridx += 1
            }
        } else {
            let imix = 1.0 - mix
            gradient.start[0] = gradient.start[0] * imix + _value[ridx] * mix
            ridx += 1
            gradient.start[1] = gradient.start[1] * imix + _value[ridx] * mix
            ridx += 1
            gradient.end[0] = gradient.end[0] * imix + _value[ridx] * mix
            ridx += 1
            gradient.end[1] = gradient.end[1] * imix + _value[ridx] * mix
            ridx += 1
            
            while (ridx < _value.count && wi < gradient.colorStops.count) {
                gradient.colorStops[wi] =
                    gradient.colorStops[wi] * imix + _value[ridx]
                ridx += 1
                wi += 1
            }
        }
        gradient.markPaintDirty()
    }
    
    func setNext(_ frame: KeyFrame) {
        // Do nothing.
    }
    
    func read(_ reader: StreamReader) -> Bool {
        if !self.readInterpolation(reader) {
            return false
        }
        let len = Int(reader.readUint16(label: "length"))
        self._value = Array.init(repeating: 0.0, count: len)
        reader.readFloat32Array(ar: &self._value, label: "value")
        return true
    }
}

class KeyFrameRadial: Interpolated {
    var _interpolator: Interpolator?
    var _time: Double = 0.0
    private var _value = [Float32]()
    
    var value: [Float32] {
        return _value
    }
    
    func applyInterpolation(component: ActorComponent, time: Double, toFrame: KeyFrame, mix: Float) {
        let radial = component as! RadialGradientColor
        let kfr = toFrame as! KeyFrameRadial
        
        var f = Float((time - _time) / (toFrame._time - _time))
        if let ip = _interpolator {
            f = ip.getEasedMix(mix: f)
        }
        
        let ff = Float32(f)
        let fi = 1.0 - ff
        
        var ridx = 0
        var wi = 0
        
        if mix == 1.0 {
            radial.secondaryRadiusScale = Double(_value[ridx] * fi + kfr._value[ridx] * ff)
            ridx += 1
            radial.start[0] = _value[ridx] * fi + kfr._value[ridx] * ff
            ridx += 1
            radial.start[1] = _value[ridx] * fi + kfr._value[ridx] * ff
            ridx += 1
            radial.end[0] = _value[ridx] * fi + kfr._value[ridx] * ff
            ridx += 1
            radial.end[1] = _value[ridx] * fi + kfr._value[ridx] * ff
            ridx += 1
            
            while ridx < kfr._value.count && wi < radial.colorStops.count {
                radial.colorStops[wi] = _value[ridx] * fi + kfr._value[ridx] * ff
                wi += 1
                ridx += 1
            }
        } else {
            let imix = 1.0 - mix
            
            // Mix : first interpolate the KeyFrames, and then mix on top of the current value.
            var val = _value[ridx] * fi + kfr._value[ridx] * ff
            radial.secondaryRadiusScale = Double(_value[ridx] * fi + kfr._value[ridx] * ff)
            ridx += 1
            val = _value[ridx] * fi + kfr._value[ridx] * ff
            radial.start[0] = _value[ridx] * imix + val * mix
            ridx += 1
            val = _value[ridx] * fi + kfr._value[ridx] * ff
            radial.start[1] = _value[ridx] * imix + val * mix
            ridx += 1
            val = _value[ridx] * fi + kfr._value[ridx] * ff
            radial.end[0] = _value[ridx] * imix + val * mix
            ridx += 1
            val = _value[ridx] * fi + kfr._value[ridx] * ff
            radial.end[1] = _value[ridx] * imix + val * mix
            ridx += 1
            
            while ridx < kfr._value.count && wi < radial.colorStops.count {
                val = _value[ridx] * fi + kfr._value[ridx] * ff
                radial.colorStops[wi] = radial.colorStops[wi] * imix + val * mix
                
                ridx += 1
                wi += 1
            }
        }
        radial.markPaintDirty()
    }
    
    func apply(component: ActorComponent, mix: Float) {
        let radial = component as! RadialGradientColor
        
        var ridx = 0
        var wi = 0
        
        
        if mix == 1.0 {
            radial.secondaryRadiusScale = Double(value[ridx])
            ridx += 1
            radial.start[0] = _value[ridx]
            ridx += 1
            radial.start[1] = _value[ridx]
            ridx += 1
            radial.end[0] = _value[ridx]
            ridx += 1
            radial.end[1] = _value[ridx]
            ridx += 1
            
            while (ridx < _value.count && wi < radial.colorStops.count) {
                radial.colorStops[wi] = _value[ridx]
                wi += 1
                ridx += 1
            }
        } else {
            let imix = 1.0 - mix
            radial.secondaryRadiusScale = radial.secondaryRadiusScale * Double(imix) + Double(_value[ridx] * mix)
            ridx += 1
            radial.start[0] = radial.start[0] * imix + _value[ridx] * mix
            ridx += 1
            radial.start[1] = radial.start[1] * imix + _value[ridx] * mix
            ridx += 1
            radial.end[0] = radial.end[0] * imix + _value[ridx] * mix
            ridx += 1
            radial.end[1] = radial.end[1] * imix + _value[ridx] * mix
            ridx += 1
            
            while ridx < _value.count && wi < radial.colorStops.count {
                radial.colorStops[wi] = radial.colorStops[wi] * imix + _value[ridx]
                ridx += 1
                wi += 1
            }
        }
        radial.markPaintDirty();
    }
    
    func setNext(_ frame: KeyFrame) {
        // Do nothing.
    }
    
    func read(_ reader: StreamReader) -> Bool {
        if !self.readInterpolation(reader) {
            return false
        }
        let len = Int(reader.readUint16(label: "length"))
        self._value = Array.init(repeating: 0.0, count: len)
        reader.readFloat32Array(ar: &self._value, label: "value")
        return true
    }
    
    
}
