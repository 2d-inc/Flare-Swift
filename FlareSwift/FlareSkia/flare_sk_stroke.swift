//
//  flare_sk_stroke.swift
//  FlareSkia
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import Skia

protocol FlareSkStroke: class {
    /**
        _paint is a sk_paint_t*
    */
    var _paint: OpaquePointer! { get set}
    /**
        effectPath is a sk_path_t*
     */
    var effectPath: OpaquePointer? { get set}
}

extension FlareSkStroke {
    
    func initializeGraphics() {
        _paint = sk_paint_new()

        let stroke = self as! ActorStroke
        sk_paint_set_stroke(_paint, true)
        sk_paint_set_stroke_width(_paint, stroke.width)
        sk_paint_set_stroke_cap(_paint, getStrokeCap(cap: stroke.cap))
        sk_paint_set_stroke_join(_paint, getStrokeJoin(cap: stroke.join))
    }
    
    func markPathEffectsDirty() {
        effectPath = nil
    }
    
    func paint(stroke: ActorStroke, skCanvas: OpaquePointer, skPath: OpaquePointer) {
        guard stroke.width > 0 else {
            return
        }
        
        sk_canvas_draw_path(skCanvas, skPath, _paint)
    }
}
