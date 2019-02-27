//
//  flare_stroke.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

protocol FlareStroke: class {
    var _strokeColor: CGColor { get set }
    var _effectPath: CGPath { get set }
    var _strokeCap: CGLineCap { get set }
    var _strokeJoin: CGLineJoin { get set }
    var _strokeWidth: CGFloat { get set }
    
    func initializeGraphics()
    func paint(stroke: ActorStroke, context: CGContext, path: CGPath)
}

extension FlareStroke {
    
    func initializeGraphics() {
        let stroke = self as! ActorStroke
        _strokeColor = CGColor.black
        _strokeCap = getStrokeCap(cap: stroke.cap)
        _strokeJoin = getStrokeJoin(join: stroke.join)
        _strokeWidth = CGFloat(stroke.width)
    }
    
    func getStrokeCap(cap: StrokeCap) -> CGLineCap {
        switch cap {
        case .Butt:
            return CGLineCap.butt
        case .Round:
            return CGLineCap.round
        case .Square:
            return CGLineCap.square
        default:
            return CGLineCap.butt
        }
    }
    
    func getStrokeJoin(join: StrokeJoin) -> CGLineJoin {
        switch join {
        case .Bevel:
            return CGLineJoin.bevel
        case .Miter:
            return CGLineJoin.miter
        case .Round:
            return CGLineJoin.round
        default:
            return CGLineJoin.miter
        }
    }
    
    func paint(stroke: ActorStroke, context: CGContext, path: CGPath) {
        guard _strokeWidth > 0 else {
            return
        }
        
        if stroke.isTrimmed {
            // TODO:
        }
        context.saveGState()
        context.setLineCap(_strokeCap)
        context.setLineJoin(_strokeJoin)
        context.setLineWidth(_strokeWidth)
        context.setStrokeColor(_strokeColor)
        context.addPath(path)
        context.strokePath()
        context.restoreGState()
    }
}

protocol FlareStrokeLinearGradient: FlareStroke {
    var _strokeGradient: CGGradient { get set }
    var _start: CGPoint { get set }
    var _end: CGPoint { get set }
    func paintStrokeGradient()
}

extension FlareStrokeLinearGradient {
    func paint(stroke: ActorStroke, context: CGContext, path: CGPath) {
        guard _strokeWidth > 0 else {
            return
        }
        
        context.saveGState() // ==
        context.setLineCap(_strokeCap)
        context.setLineJoin(_strokeJoin)
        context.setLineWidth(_strokeWidth)
        context.setStrokeColor(_strokeColor)
        context.addPath(path)
        context.replacePathWithStrokedPath()
        context.clip()
        context.drawLinearGradient(_strokeGradient, start: _start, end: _end, options: [])
        context.restoreGState() // ==
    }
}
