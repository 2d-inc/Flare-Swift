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
    /// paint is of type `sk_paint_t*` (i.e. C-style pointer)
    var _paint: OpaquePointer! { get set }
    /// effectPath is of type `sk_path_t*` (i.e. C-style pointer)
    var effectPath: OpaquePointer? { get set }
    func onPaintUpdated(_ paint: OpaquePointer)
}

extension FlareSkStroke {
    
    func initializeGraphics() {
        _paint = sk_paint_new()

        let stroke = self as! ActorStroke
        sk_paint_set_stroke(_paint, true)
        sk_paint_set_antialias(_paint, true)
        sk_paint_set_stroke_width(_paint, stroke.width)
        sk_paint_set_stroke_cap(_paint, getStrokeCap(cap: stroke.cap))
        sk_paint_set_stroke_join(_paint, getStrokeJoin(cap: stroke.join))
        onPaintUpdated(_paint)
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
    
    func onPaintUpdated(_ paint: OpaquePointer) {
        /**
           Optional.
        */
    }
}
