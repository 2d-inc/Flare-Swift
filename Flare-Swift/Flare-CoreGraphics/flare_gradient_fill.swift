//
//  flare_gradient_fill.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class FlareGradientFill: GradientFill, FlareFill {
    var _paint: CGColor = CGColor.black
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceGradientFill = FlareGradientFill()
        instanceGradientFill.copyGradientFill(self, resetArtboard)
        return instanceGradientFill
    }
    
    override func update(dirt: UInt8) {
        super.update(dirt: dirt)
        var colors = [CGColor]()
        var stops = [CGFloat]()
        let cs = colorStops
        let numStops = Int(round(Double(cs.count) / 5))
        
        var idx = 0
        for i in 0 ..< numStops {
            let r = CGFloat(round(cs[idx]))
            let g = CGFloat(round(cs[idx+1]))
            let b = CGFloat(round(cs[idx+2]))
            let a = CGFloat(cs[idx+3])
            colors.append(CGColor(red: r, green: g, blue: b, alpha: a))
            stops.append(CGFloat(cs[idx+4]))
            idx += 5
        }
        
        var paintColor: CGColor
        if let overrideColor = artboard!.overrideColor {
            let r = CGFloat(round(overrideColor[0]))
            let g = CGFloat(round(overrideColor[1]))
            let b = CGFloat(round(overrideColor[2]))
            let a = CGFloat(Double(overrideColor[3]) * artboard!.modulateOpacity * opacity * shape.renderOpacity)
            paintColor = CGColor(red: r, green: g, blue: b, alpha: a)
        } else {
            let alpha = min(max(artboard!.modulateOpacity * opacity * shape.renderOpacity, 0,0), 1.0)// Clamp
            paintColor = CGColor(red: 1, green: 1, blue: 1, alpha: CGFloat(alpha)) // White w/ custom alpha.
        }
        
        _paint = paintColor
    }
}
