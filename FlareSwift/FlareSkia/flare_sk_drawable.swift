//
//  flare_sk_drawable.swift
//  FlareSkia
//
//  Created by Umberto Sonnino on 3/19/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import Skia

protocol FlareSkDrawable: class {
    var _blendMode: BlendMode { get set }
    
    func draw(_ skCanvas: OpaquePointer)
    func onBlendModeChanged(_ mode: BlendMode)
}

enum BlendMode: UInt32 {
    case Clear = 0,
    Src,
    Dst,
    SrcOver,
    DstOver,
    SrcIn,
    DstIn,
    SrcOut,
    DstOut,
    SrcATop,
    DstATop,
    Xor,
    Plus,
    Modulate,
    Screen,
    Overlay,
    Darken,
    Lighten,
    ColorDodge,
    ColorBurn,
    HardLight,
    SoftLight,
    Difference,
    Exclusion,
    Multiply,
    Hue,
    Saturation,
    Color,
    Luminosity
    
    var skType: sk_xfermode_mode_t {
        return sk_xfermode_mode_t(rawValue: 26)
    }
}

extension FlareSkDrawable {
    var blendMode: BlendMode {
        get {
            return _blendMode
        }
        set {
            if _blendMode != newValue {
                _blendMode = newValue
                onBlendModeChanged(_blendMode)
            }
        }
    }
    
    var blendModeId: UInt32 {
        get {
            return _blendMode.rawValue
        }
        set {
            if _blendMode.rawValue != newValue {
                _blendMode = BlendMode.init(rawValue: newValue)!
            }
        }
    }
}
