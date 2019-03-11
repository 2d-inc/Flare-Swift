//
//  flare_shape.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class FlareShape: ActorShape {
    private var _isValid = false
    private var _path = CGMutablePath()
    
    override func invalidateShape() {
        _isValid = false
        stroke?.markPathEffectsDirty()
    }
    
    var piecewiseBezierPaths: [PiecewiseBezier] {
        var allPaths = [PiecewiseBezier]()
        if let c = children {
            for node in c {
                if let flarePath = node as? FlarePath {
                    let beziers = flarePath.beziers
                    let piecewise = PiecewiseBezier(beziers)
                    if let pathTransform = (node as! ActorBasePath).pathTransform {
                        let a = CGFloat(pathTransform[0])
                        let b = CGFloat(pathTransform[1])
                        let c = CGFloat(pathTransform[2])
                        let d = CGFloat(pathTransform[3])
                        let tx = CGFloat(pathTransform[4])
                        let ty = CGFloat(pathTransform[5])
                        let cgAffine = CGAffineTransform(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
//                        _path.addPath(flarePath.path, transform: cgAffine)
                        piecewise.transform = cgAffine
                    }
                    
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
                if let flarePath = node as? FlarePath {
                    let cgPath = flarePath.path
                    if let pathTransform = (node as! ActorBasePath).pathTransform {
                        let a = CGFloat(pathTransform[0])
                        let b = CGFloat(pathTransform[1])
                        let c = CGFloat(pathTransform[2])
                        let d = CGFloat(pathTransform[3])
                        let tx = CGFloat(pathTransform[4])
                        let ty = CGFloat(pathTransform[5])
                        let cgAffine = CGAffineTransform(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
                        _path.addPath(cgPath, transform: cgAffine)
                    } else {
                        _path.addPath(cgPath)
                    }
                }
            }
        }
        return _path
    }
    
    func draw(context: CGContext) {
        guard self.doesDraw else {
            return
        }
        
        context.saveGState()
        
        let renderPath = self.path

        // Get Clips
        for clips in clipShapes {
            let clippingPath = CGMutablePath()
            for clipShape in clips {
                clippingPath.addPath((clipShape as! FlareShape).path)
            }
            context.addPath(clippingPath)
            context.clip()
        }
        
        for actorFill in fills {
            let fill = actorFill as! FlareFill
            fill.paint(fill: actorFill, context: context, path: renderPath)
        }
        
        var strokePath = renderPath
        for actorStroke in strokes {
            let stroke = actorStroke as! FlareStroke
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
                            stroke.effectPath = trimPath(pbPaths, start, end, false, isSequential)
                        } else {
                            stroke.effectPath = trimPath(pbPaths, end, start, true, isSequential)
                        }
                    } else {
                        stroke.effectPath = renderPath
                    }
                }
                strokePath = stroke.effectPath!
            }
            stroke.paint(stroke: actorStroke, context: context, path: strokePath)
        }
        
        context.restoreGState()
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceShape = FlareShape()
        instanceShape.copyShape(self, resetArtboard)
        return instanceShape
    }
}
