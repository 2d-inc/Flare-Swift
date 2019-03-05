//
//  flare_shape.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class FlareShape: ActorShape {
    var _isValid = false
    var _path = CGMutablePath()
    
    override func invalidateShape() {
        _isValid = false
        stroke?.markPathEffectsDirty()
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
                    let pathTransform = (node as! ActorBasePath).pathTransform
                    let a = CGFloat(pathTransform![0])
                    let b = CGFloat(pathTransform![1])
                    let c = CGFloat(pathTransform![2])
                    let d = CGFloat(pathTransform![3])
                    let tx = CGFloat(pathTransform![4])
                    let ty = CGFloat(pathTransform![5])
                    let cgAffine = CGAffineTransform(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
                    _path.addPath(flarePath.path, transform: cgAffine)
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
        
        let renderPath = path
        
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
        
        for actorStroke in strokes {
            let stroke = actorStroke as! FlareStroke
            stroke.paint(stroke: actorStroke, context: context, path: renderPath)
        }
        
        context.restoreGState()
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceShape = FlareShape()
        instanceShape.copyShape(self, resetArtboard)
        return instanceShape
    }
}
