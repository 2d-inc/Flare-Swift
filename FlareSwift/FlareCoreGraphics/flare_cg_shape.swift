//
//  flare_cg_shape.swift
//  FlareCoreGraphics
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class FlareCGShape: ActorShape, FlareCGDrawable {
    private var _isValid = false
    private var _path = CGMutablePath()
    var _layer = CALayer()
    
    var piecewiseBezierPaths: [PiecewiseBezier<CGMutablePath>] {
        var allPaths = [PiecewiseBezier<CGMutablePath>]()
        if let c = children {
            for node in c {
                if let actorPath = node as? ActorBasePath {
                    let beziers = makeBeziers(from: actorPath)
                    let piecewise = PiecewiseBezier<CGMutablePath>(beziers)
                    piecewise.transform = actorPath.pathTransform ?? Mat2D()                    
                    allPaths.append(piecewise)
                }
            }
        }
        
        return allPaths
    }
    
    var path: CGPath {
        if _isValid {
            return _path
        }
        
        _isValid = true
        _path = CGMutablePath()
        
        if let c = children {
            for node in c {
                if let flarePath = node as? FlareCGPath {
                    let cgPath = flarePath.path
                    if let pathTransform = (node as! ActorBasePath).pathTransform {
                        let a = CGFloat(pathTransform[0])
                        let b = CGFloat(pathTransform[1])
                        let c = CGFloat(pathTransform[2])
                        let d = CGFloat(pathTransform[3])
                        let tx = CGFloat(pathTransform[4])
                        let ty = CGFloat(pathTransform[5])
                        let cgAffine = CGAffineTransform(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
//                        print("TRANSFORM: \(cgAffine)")
                        _path.addPath(cgPath, transform: cgAffine)
                    } else {
                        _path.addPath(cgPath)
                    }
                }
            }
        }
        return _path
    }
    
    override func invalidateShape() {
        _isValid = false
        stroke?.markPathEffectsDirty()
    }
    
    private func removeSublayers() {
        if let sublayers = _layer.sublayers {
            for sublayer in sublayers {
                sublayer.removeFromSuperlayer()
            }
        }
    }
    
    func draw(on: CALayer) {
        // Cleanup
        removeSublayers()
        
        guard self.doesDraw else {
            return
        }

        if _layer.superlayer != on {
            on.addSublayer(_layer)
        }
        
        let renderPath = self.path

        // Get Clips
        if !clipShapes.isEmpty {
            let maskingLayer = CAShapeLayer()
            let clippingPath = CGMutablePath()
            maskingLayer.frame = CGRect(x: 0, y: 0, width: _layer.bounds.width, height: _layer.bounds.height)
            _layer.mask = maskingLayer
            
            for clips in clipShapes {
                for clipShape in clips {
                    clippingPath.addPath((clipShape as! FlareCGShape).path)
                }
            }
            maskingLayer.path = clippingPath
        }
        
        for actorFill in fills {
            let fill = actorFill as! FlareCGFill
            fill.paint(fill: actorFill, on: _layer, path: renderPath)
        }
        
        var strokePath = renderPath
        for actorStroke in strokes {
            let stroke = actorStroke as! FlareCGStroke
            if actorStroke.isTrimmed {
                if stroke.effectPath == nil {
                    let pbPaths = self.piecewiseBezierPaths
                    let isSequential = actorStroke._trim == .Sequential
                    var start = actorStroke.trimStart
                    var end = actorStroke.trimEnd
                    let offset = actorStroke.trimOffset
                    let inverted = start > end
//                    print("TRIM START \(start) END \(end) OFFSET \(offset)")
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
//                        print("=>=> \(start) END \(end)")
                        if end >= start {
                            let trim = trimPath(pbPaths, start, end, false, isSequential)
                            stroke.effectPath = (trim as! CGMutablePath)
                        } else {
                            let trim = trimPath(pbPaths, end, start, true, isSequential)
                            stroke.effectPath = (trim as! CGMutablePath)
                        }
                    } else {
                        stroke.effectPath = renderPath
                    }
                }
                strokePath = stroke.effectPath!
            }
            stroke.paint(stroke: actorStroke, on: _layer, path: strokePath)
        }
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceShape = FlareCGShape()
        instanceShape.copyShape(self, resetArtboard)
        return instanceShape
    }
}
