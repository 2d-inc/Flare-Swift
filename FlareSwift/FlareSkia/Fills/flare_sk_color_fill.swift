//
//  flare_sk_color_fill.swift
//  FlareSkia
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import Skia

class FlareSkColorFill: ColorFill, FlareSkFill {
    var _paint: OpaquePointer!
    
    override func initializeGraphics() {
        (self as FlareSkFill).initializeGraphics()
    }
    
    var uiColor: UInt32 {
        get {
            let c = color
            let alpha = round(Double(c[3]) * 255 * artboard!.modulateOpacity * opacity * shape.renderOpacity)
            let clampedAlpha = min(max(alpha, 0.0), 255.0)
            let res: UInt32 = sk_color_set_argb(
                UInt32(clampedAlpha),
                UInt32(round(c[0] * 255)),
                UInt32(round(c[1] * 255)),
                UInt32(round(c[2] * 255))
            )
            return res
        }
        set(c) {
            let r = Float32(sk_color_get_r(c))/255
            let b = Float32(sk_color_get_b(c))/255
            let g = Float32(sk_color_get_g(c))/255
            let a = Float32(sk_color_get_a(c))/255
            color = [r,g,b,a]
        }
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceFill = FlareSkColorFill()
        instanceFill.copyColorFill(self, resetArtboard)
        return instanceFill
    }
    
    override func update(dirt: UInt8) {
        super.update(dirt: dirt)
        sk_paint_set_color(_paint, uiColor)
        sk_paint_set_xfermode_mode(_paint, (parent as! FlareSkShape).blendMode.skType)
        onPaintUpdated(_paint)
    }
}
