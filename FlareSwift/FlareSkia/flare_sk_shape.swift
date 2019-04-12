//
//  flare_sk_shape.swift
//  FlareSkia
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import Skia

class FlareSkShape: ActorShape, FlareSkDrawable {
    private var _isValid = false
    private var _path: OpaquePointer! = sk_path_new()
    
    override func invalidateShape() {
        _isValid = false
        stroke?.markPathEffectsDirty()
    }
    
    var path: OpaquePointer {
        if _isValid {
            return _path
        }
        
        _isValid = true
        sk_path_reset(_path)
        
        if let c = children {
            for node in c {
                if let flarePath = node as? FlareSkPath {
                    let subpath = flarePath.path
                    if let pathTransform = (node as! ActorBasePath).pathTransform {
                        let buffer = pathTransform._buffer
                        var skMat = sk_matrix_t(
                            mat: (
                                buffer[0],
                                buffer[1],
                                0.0,
                                buffer[2],
                                buffer[3],
                                0.0,
                                buffer[4],
                                buffer[5],
                                1.0
                            )
                        )
                        let matPointer = withUnsafeMutablePointer(to: &skMat){
                            UnsafeMutablePointer($0)
                        }
                        sk_path_add_path_with_matrix(_path, subpath, 0, 0, matPointer)
                    } else {
                        sk_path_add_path(_path, subpath, 0, 0)
                    }
                }
            }
        }
        return _path
    }
    
    /**
     Implements FlareSkDrawable draw(skCanvas:)
    */
    func draw(_ skCanvas: OpaquePointer) {
        guard self.doesDraw else {
            return
        }
        
        sk_canvas_save(skCanvas)
        
        let renderPath = self.path

        // Get Clips
        for clips in clipShapes {
            let clippingPath = sk_path_new()
            for clipShape in clips {
                let subClip = (clipShape as! FlareSkShape).path
                sk_path_add_path(clippingPath, subClip, 0, 0)
            }
            sk_canvas_clip_path(skCanvas, clippingPath)
        }
        
        for actorFill in fills {
            let fill = actorFill as! FlareSkFill
            fill.paint(fill: actorFill, skCanvas: skCanvas, skPath: renderPath)
        }
        
        for actorStroke in strokes {
            let stroke = actorStroke as! FlareSkStroke
            stroke.paint(stroke: actorStroke, skCanvas: skCanvas, skPath: renderPath)
        }
        
        sk_canvas_restore(skCanvas)
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceShape = FlareSkShape()
        instanceShape.copyShape(self, resetArtboard)
        return instanceShape
    }
}
