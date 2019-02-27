//
//  flare_color_stroke.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class FlareColorStroke: ColorStroke, FlareStroke {
    var _strokeColor: CGColor = CGColor.black
    var _effectPath: CGPath = CGMutablePath()
    var _strokeCap: CGLineCap = CGLineCap.butt
    var _strokeJoin: CGLineJoin = .miter
    var _strokeWidth: CGFloat = 0.0
    
    private var cgColor: CGColor {
        get {
            let c = color
            let r = CGFloat(c[0])
            let g = CGFloat(c[1])
            let b = CGFloat(c[2])
            let a = CGFloat(Double(c[3]) * artboard!.modulateOpacity * opacity * shape.renderOpacity)
            return CGColor(red: r, green: g, blue: b, alpha: a)
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
        let instanceColorStroke = FlareColorStroke()
        instanceColorStroke.copyColorStroke(self, resetArtboard)
        return instanceColorStroke
    }
    
    override func update(dirt: UInt8) {
        super.update(dirt: dirt)
        _strokeColor = cgColor
        _strokeWidth = CGFloat(width)
    }
    
}
