//
//  flare_sk_shape.swift
//  FlareSkia
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import Skia
import os.log

class FlareSkShape: ActorShape, FlareSkDrawable {
    var _blendMode: BlendMode = .SrcOver
    
    private var _isValid = false
    private var _path: OpaquePointer!
    
    override func initializeGraphics() {
        super.initializeGraphics()
        _path = sk_path_new()
        for path in paths {
            if let skiaPath = path as? FlareSkPath {
                skiaPath.initializeGraphics()
            } else {
                os_log("Couldn't cast path to FlareSkPath!", type: .debug)
            }
        }
    }
    
    override var blendModeId: UInt32 {
        get {
            return (self as FlareSkDrawable).blendModeId
        }
        set {
            (self as FlareSkDrawable).blendModeId = newValue
        }
    }
    
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
        
        if let pathFill = fill, pathFill.fillRule == .EvenOdd {
            sk_path_set_evenodd(_path, true)
        } else {
            sk_path_set_evenodd(_path, true)
        }
        
        for path in paths {
            let skiaPath = path as! FlareSkPath
            let subPath = skiaPath.path // Calls the getter.
            if let pathTransform = path.pathTransform {
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
                sk_path_add_path_with_matrix(_path, subPath, 0, 0, matPointer)
            } else {
                sk_path_add_path(_path, subPath, 0, 0)
            }
        }

        return _path
    }
    
    func getRenderPath(_ skCanvas: OpaquePointer) -> OpaquePointer {
        return path // Call to the getter.
    }
    
    /// Implements FlareSkDrawable `draw(skCanvas:)`
    func draw(_ skCanvas: OpaquePointer) {
        guard self.doesDraw else {
            return
        }
        
        sk_canvas_save(skCanvas)

        clip(skCanvas)
        
        let renderPath = getRenderPath(skCanvas)
        
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
    
    func onBlendModeChanged(_ mode: BlendMode) {
        for actorFill in fills {
            (actorFill as! ActorPaint).markPaintDirty()
        }
        for actorStroke in strokes {
            actorStroke.markPaintDirty()
        }
    }
}
