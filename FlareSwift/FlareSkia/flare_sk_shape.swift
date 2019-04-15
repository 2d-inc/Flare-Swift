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
    
    var piecewiseBezierPaths: [PiecewiseBezier<SkPath>] {
        var allPaths = [PiecewiseBezier<SkPath>]()
        if let c = children {
            for node in c {
                if let actorPath = node as? ActorBasePath {
                    let beziers = makeBeziers(from: actorPath)
                    let piecewise = PiecewiseBezier<SkPath>(beziers)
                    piecewise.transform = actorPath.pathTransform ?? Mat2D()
                    allPaths.append(piecewise)
                }
            }
        }
        
        return allPaths
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
                        // Indices are adjusted to sk_matrix_t that is in row-major order.
                        var skMat = sk_matrix_t(
                            mat: (
                                pathTransform[0],
                                pathTransform[2],
                                pathTransform[4],
                                pathTransform[1],
                                pathTransform[3],
                                pathTransform[5],
                                0, 0, 1.0
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
    
    /// Implements FlareSkDrawable `draw(skCanvas:)`
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
            // bool flag enables antialiasing.
            sk_canvas_clip_path(skCanvas, clippingPath, true)
        }
        
        for actorFill in fills {
            let fill = actorFill as! FlareSkFill
            fill.paint(fill: actorFill, skCanvas: skCanvas, skPath: renderPath)
        }
        
        for actorStroke in strokes {
            let stroke = actorStroke as! FlareSkStroke
            
            var strokePath = renderPath
            if actorStroke.isTrimmed {
                if stroke.effectPath == nil {
                    let pbPaths = self.piecewiseBezierPaths
                    let isSequential = actorStroke._trim == .Sequential
                    var start = actorStroke.trimStart
                    var end = actorStroke.trimEnd
                    let offset = actorStroke.trimOffset
                    let inverted = start > end
                    if abs(start-end) != 1.0 {
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
                            let trim = trimPath(pbPaths, start, end, false, isSequential)
                            stroke.effectPath = (trim as! SkPath).skPath
                        } else {
                            let trim = trimPath(pbPaths, end, start, true, isSequential)
                            stroke.effectPath = (trim as! SkPath).skPath
                        }
                    } else {
                        stroke.effectPath = renderPath
                    }
                }
                strokePath = stroke.effectPath!
            }
            
            stroke.paint(stroke: actorStroke, skCanvas: skCanvas, skPath: strokePath)
        }
        
        sk_canvas_restore(skCanvas)
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceShape = FlareSkShape()
        instanceShape.copyShape(self, resetArtboard)
        return instanceShape
    }
}
