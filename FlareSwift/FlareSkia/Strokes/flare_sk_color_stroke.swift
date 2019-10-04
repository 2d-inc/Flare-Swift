//
//  flare_sk_color_stroke.swift
//  FlareSkia
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import Skia

class FlareSkColorStroke: ColorStroke, FlareSkStroke {
    var _paint: OpaquePointer!
    var effectPath: OpaquePointer?
    
    override func initializeGraphics() {
        (self as FlareSkStroke).initializeGraphics()
    }
    
    override func markPathEffectsDirty() {
        effectPath = nil
    }
    
    private var uiColor: UInt32 {
        get {
            let c = color
            let r = UInt32(c[0] * 255)
            let g = UInt32(c[1] * 255)
            let b = UInt32(c[2] * 255)
            let a = min(max(UInt32(Double(c[3]) * artboard!.modulateOpacity * opacity * shape.renderOpacity * 255), 0), 1)
            return sk_color_set_argb(a, r, g, b)
        }
        set(c) {
            let r = Float32(sk_color_get_a(c)/255)
            let b = Float32(sk_color_get_b(c)/255)
            let g = Float32(sk_color_get_g(c)/255)
            let a = Float32(sk_color_get_a(c)/255)
            color = [r,g,b,a]
        }
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceColorStroke = FlareSkColorStroke()
        instanceColorStroke.copyColorStroke(self, resetArtboard)
        return instanceColorStroke
    }
    
    override func update(dirt: UInt8) {
        super.update(dirt: dirt)
        sk_paint_set_color(_paint, uiColor)
        sk_paint_set_stroke_width(_paint, width)
        sk_paint_set_xfermode_mode(_paint, (parent as! FlareSkShape).blendMode.skType)
    }
}
