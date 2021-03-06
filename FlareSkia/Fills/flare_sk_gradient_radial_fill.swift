//
//  flare_sk_gradient_radial_fill.swift
//  FlareSkia
//
//  Created by Umberto Sonnino on 3/5/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import Skia

class FlareSkRadialFill: RadialGradientFill, FlareSkFill {
    var _paint: OpaquePointer!
    
    override func initializeGraphics() {
        (self as FlareSkFill).initializeGraphics()
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let radialNode = FlareSkRadialFill()
        radialNode.copyRadialFill(self, resetArtboard)
        return radialNode
    }
    
    override func update(dirt: UInt8) {
        super.update(dirt: dirt)

        let radius = Vec2D.distance(renderStart, renderEnd)
        let numStops = Int32(round( Double(colorStops.count)/5 ))
        var colors = [sk_color_t]()
        var locations = [Float32]()
        
        var idx = 0
        for _ in 0 ..< numStops {
            let r = UInt32(colorStops[idx]*255)
            let g = UInt32(colorStops[idx+1]*255)
            let b = UInt32(colorStops[idx+2]*255)
            let a = min(max(UInt32(colorStops[idx+3]*255), 0), 255)
            colors.append(sk_color_set_argb(a, r, g, b))
            locations.append(colorStops[idx+4])
            idx += 5
        }
        
        var paintColor: sk_color_t
        if let overrideColor = artboard!.overrideColor {
            let r = UInt32(overrideColor[0]*255)
            let g = UInt32(overrideColor[1]*255)
            let b = UInt32(overrideColor[2]*255)
            let a = min(max(UInt32(Double(overrideColor[3]) * artboard!.modulateOpacity * opacity * shape.renderOpacity * 255), 0), 255)
            paintColor = sk_color_set_argb(a,r,g,b)
        } else {
            let alpha = min(max(artboard!.modulateOpacity * opacity * shape.renderOpacity * 255, 0,0), 255.0) // Clamp
            paintColor = sk_color_set_argb(UInt32(alpha), 0xFF, 0xFF, 0xFF) // White w/ custom alpha
        }
        
        sk_paint_set_color(_paint, paintColor)
        sk_paint_set_xfermode_mode(_paint, (parent as! FlareSkShape).blendMode.skType)
        let start = sk_point_t(x: renderStart[0], y: renderStart[1])
        let end = sk_point_t(x: renderEnd[0], y: renderEnd[1])
        let shader = sk_shader_new_radial_gradient([start, end], radius, colors, locations, numStops, CLAMP_SK_SHADER_TILEMODE, nil)
        sk_paint_set_shader(_paint, shader)
        sk_shader_unref(shader)
    }
}
