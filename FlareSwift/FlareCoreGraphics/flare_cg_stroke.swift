//
//  flare_cg_stroke.swift
//  FlareCoreGraphics
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import CoreGraphics

protocol FlareCGStroke: class {
    var _strokeLayer: CALayer { get set }
    var _color: CGColor { get set }
    var _strokeCap: CAShapeLayerLineCap { get set }
    var _strokeJoin: CAShapeLayerLineJoin { get set }
    var _strokeWidth: CGFloat { get set }
    var effectPath: CGPath? { get set }
    
    func initializeGraphics()
    func paint(stroke: ActorStroke, on: CALayer, path: CGPath)
}

extension FlareCGStroke {
    
    func initializeGraphics() {
        let stroke = self as! ActorStroke
        _color = CGColor.black
        _strokeCap = self.strokeCap
        _strokeJoin = self.strokeJoin
        _strokeWidth = CGFloat(stroke.width)
    }
    
    var strokeCap: CAShapeLayerLineCap {
        let stroke = self as! ActorStroke
        switch stroke.cap {
        case .Butt:
            return .butt
        case .Round:
            return .round
        case .Square:
            return .square
        }
    }
    
    var strokeJoin: CAShapeLayerLineJoin {
        let stroke = self as! ActorStroke
        switch stroke.join {
        case .Bevel:
            return .bevel
        case .Miter:
            return .miter
        case .Round:
            return .round
        }
    }
    
    func markPathEffectsDirty() {
        effectPath = nil
    }
}
