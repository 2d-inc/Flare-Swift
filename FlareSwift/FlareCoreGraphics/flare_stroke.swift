//
//  flare_stroke.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

protocol FlareStroke: class {
    var _color: CGColor { get set }
    var _strokeCap: CGLineCap { get set }
    var _strokeJoin: CGLineJoin { get set }
    var _strokeWidth: CGFloat { get set }
    var effectPath: CGPath? { get set }
    
    func initializeGraphics()
    func paint(stroke: ActorStroke, context: CGContext, path: CGPath)
}

extension FlareStroke {
    
    func initializeGraphics() {
        let stroke = self as! ActorStroke
        _color = CGColor.black
        _strokeCap = self.strokeCap
        _strokeJoin = self.strokeJoin
        _strokeWidth = CGFloat(stroke.width)
    }
    
    var strokeCap: CGLineCap {
        let stroke = self as! ActorStroke
        switch stroke.cap {
        case .Butt:
            return CGLineCap.butt
        case .Round:
            return CGLineCap.round
        case .Square:
            return CGLineCap.square
        }
    }
    
    var strokeJoin: CGLineJoin {
        let stroke = self as! ActorStroke
        switch stroke.join {
        case .Bevel:
            return CGLineJoin.bevel
        case .Miter:
            return CGLineJoin.miter
        case .Round:
            return CGLineJoin.round
        }
    }
    
    func markPathEffectsDirty() {
        effectPath = nil
    }
}
