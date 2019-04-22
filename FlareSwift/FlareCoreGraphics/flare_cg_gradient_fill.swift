//
//  flare_cg_gradient_fill.swift
//  FlareCoreGraphics
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class FlareCGGradientFill: GradientFill, FlareCGFill {
    var _fillColor = CGColor.black
    var _gradientColors: [CGColor]!
    var _gradientLocations: [NSNumber]!
    
    var _fillLayer: CALayer = CAGradientLayer()
    let gradientMask = CAShapeLayer()
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceGradientFill = FlareCGGradientFill()
        instanceGradientFill.copyGradientFill(self, resetArtboard)
        return instanceGradientFill
    }
    
    override func update(dirt: UInt8) {
        super.update(dirt: dirt)
        
        let numStops = Int(round( Double(colorStops.count)/5 ))
        _gradientLocations = []
        _gradientColors = []
        
        var idx = 0
        for _ in 0 ..< numStops {
            let r = CGFloat(colorStops[idx])
            let g = CGFloat(colorStops[idx+1])
            let b = CGFloat(colorStops[idx+2])
            let a = CGFloat(colorStops[idx+3])
            _gradientColors.append(CGColor.cgColor(red: r, green: g, blue: b, alpha: a))
            _gradientLocations.append(NSNumber(value: colorStops[idx+4]))
            idx += 5
        }
        
        var paintColor: CGColor!
        if let overrideColor = artboard!.overrideColor {
            let r = CGFloat(round(overrideColor[0]))
            let g = CGFloat(round(overrideColor[1]))
            let b = CGFloat(round(overrideColor[2]))
            let a = CGFloat(Double(overrideColor[3]) * artboard!.modulateOpacity * opacity * shape.renderOpacity)
            paintColor = CGColor.cgColor(red: r, green: g, blue: b, alpha: a)
        } else {
            let alpha = min(max(artboard!.modulateOpacity * opacity * shape.renderOpacity, 0,0), 1.0) // Clamp
            paintColor = CGColor.cgColor(red: 1, green: 1, blue: 1, alpha: CGFloat(alpha)) // White w/ custom alpha.
        }
        
        _fillColor = paintColor
    }
    
    func paint(fill: ActorFill, on: CALayer, path: CGPath) {
        let bounds = on.bounds
        let width = Float(bounds.width)
        let height = Float(bounds.height)
        let startPoint = CGPoint(x: renderStart[0]/width, y: renderStart[1]/height)
        let endPoint = CGPoint(x: renderEnd[0]/width, y: renderEnd[1]/height)
        
        gradientMask.path = path
        gradientMask.fillColor = _fillColor
        gradientMask.fillRule = self.fillRule
        
        let gradientLayer = _fillLayer as! CAGradientLayer
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.colors = _gradientColors
        gradientLayer.locations = _gradientLocations
        gradientLayer.frame = bounds
        gradientLayer.mask = gradientMask
        
        on.addSublayer(gradientLayer)
    }
}
