//
//  flare_color_fill.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class FlareColorFill: ColorFill, FlareFill {
    var _paint = CGColor.black
    
    var uiColor: CGColor {
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
        let instanceFill = FlareColorFill()
        instanceFill.copyColorFill(self, resetArtboard)
        return instanceFill
    }
    
    override func update(dirt: UInt8) {
        super.update(dirt: dirt)
        _paint = self.uiColor
    }
}
