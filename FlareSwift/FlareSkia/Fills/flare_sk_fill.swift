//
//  flare_sk_fill.swift
//  FlareSkia
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import Skia

protocol FlareSkFill: class {
    /**
        _paint is of type sk_paint_t*
    */
    var _paint: OpaquePointer! { get set }
}

extension FlareSkFill {    
    func initializeGraphics() {
        // SkPaint is initialized as a black fill.
        _paint = sk_paint_new()
        sk_paint_set_antialias(_paint, true)
    }
    
    func paint(fill: ActorFill, skCanvas: OpaquePointer, skPath: OpaquePointer) {
        switch fill.fillRule {
        case .EvenOdd:
            sk_path_set_evenodd(skPath, true)
            break
        case .NonZero:
            sk_path_set_evenodd(skPath, false)
            break
        }
        sk_canvas_draw_path(skCanvas, skPath, _paint)
    }
}
