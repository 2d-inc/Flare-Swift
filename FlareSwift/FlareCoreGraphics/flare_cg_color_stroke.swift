//
//  flare_cg_color_stroke.swift
//  FlareCoreGraphics
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class FlareCGColorStroke: ColorStroke, FlareCGStroke {
    var _color: CGColor = CGColor.black
    var _strokeCap: CAShapeLayerLineCap = .butt
    var _strokeJoin: CAShapeLayerLineJoin = .miter
    var _strokeWidth: CGFloat = 0.0
    var effectPath: CGPath? = nil
    
    var _strokeLayer: CALayer = CAShapeLayer()
    
    override func markPathEffectsDirty() {
        effectPath = nil
    }
    
    private var cgColor: CGColor {
        get {
            let c = color
            let r = CGFloat(c[0])
            let g = CGFloat(c[1])
            let b = CGFloat(c[2])
            let a = CGFloat(Double(c[3]) * artboard!.modulateOpacity * opacity * shape.renderOpacity)
            return CGColor.cgColor(red: r, green: g, blue: b, alpha: a)
        }
        set(c) {
            let components = c.components!
            let r = Float32(components[0])
            let g = Float32(components[1])
            let b = Float32(components[2])
            let a = Float32(components[3])
            color = [r,g,b,a]
        }
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceColorStroke = FlareCGColorStroke()
        instanceColorStroke.copyColorStroke(self, resetArtboard)
        return instanceColorStroke
    }
    
    override func update(dirt: UInt8) {
        super.update(dirt: dirt)
        _color = cgColor
        _strokeWidth = CGFloat(width)
    }
    
    func paint(stroke: ActorStroke, on: CALayer, path: CGPath) {
        guard _strokeWidth > 0 else {
            return
        }
        
        let strokeLayer = _strokeLayer as! CAShapeLayer
        // Remove fill color and just stroke this layer.
        strokeLayer.fillColor = CGColor.clear
        strokeLayer.path = path
        strokeLayer.strokeColor = _color
        strokeLayer.lineWidth = _strokeWidth
        strokeLayer.lineJoin = strokeJoin
        
        on.addSublayer(strokeLayer)
    }
}
