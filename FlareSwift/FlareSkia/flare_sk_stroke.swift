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
        
        var path = skPath
        
        if stroke.isTrimmed {
            if let effect = effectPath {
                path = effect
            } else {
                // effectPath is null (invalid).
                let isSequential = stroke._trim == .Sequential
                let offset = stroke.trimOffset
                
                var start = stroke.trimStart
                var end = stroke.trimEnd
                
                let inverted = start > end
                
                if abs(start-end) != 1 {
                    start = (start + offset).truncatingRemainder(dividingBy: 1.0)
                    end = (end + offset).truncatingRemainder(dividingBy: 1.0)
                    
                    if start < 0 {
                        start += 1
                    }
                    if end < 0 {
                        end += 1
                    }
                    
                    if inverted {
                        let swap = end
                        end = start
                        start = swap
                    }
                    if end >= start {
                        effectPath = path
                        // TODO: effectPath = skTrimPath(path, start, end, false, isSequential)
                    } else {
                        effectPath = path
                        // TODO: effectPath = skTrimPath(path, end, start, true, isSequential)
                    }
                } else {
                    effectPath = path
                }
            }
        }
        sk_canvas_draw_path(skCanvas, path, _paint)
    }
}
