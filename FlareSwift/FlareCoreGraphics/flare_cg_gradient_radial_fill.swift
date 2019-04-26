//
//  flare_cg_gradient_radial_fill.swift
//  FlareCoreGraphics
//
//  Created by Umberto Sonnino on 3/5/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class FlareCGRadialFill: RadialGradientFill, FlareCGFill {
    var _fillColor: CGColor = CGColor.black
    
    var _gradientColors: [CGColor]!
    var _gradientLocations: [Float32]!

    var _fillLayer: CALayer = CAGradientLayer()
    let gradientMask = CAShapeLayer()

    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let radialNode = FlareCGRadialFill()
        radialNode.copyRadialFill(self, resetArtboard)
        return radialNode
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
            _gradientLocations.append(colorStops[idx+4])
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
        gradientMask.path = path
        gradientMask.fillColor = _fillColor
        gradientMask.fillRule = self.fillRule

        let onBounds = on.bounds
        let gradientFrame = CGRect(x: 0, y: 0, width: onBounds.width, height: onBounds.height)
        if !_fillLayer.frame.equalTo(gradientFrame) {
            _fillLayer.frame = gradientFrame
        }
        _fillLayer.mask = gradientMask
        
        let fWidth = Float(onBounds.width)
        let fHeight = Float(onBounds.height)
        let radius = Vec2D.distance(renderEnd, renderStart)
        
        let center = CGPoint(
            x: renderStart[0]/fWidth,
            y: renderStart[1]/fHeight
        )
        let to = CGPoint(
            x: (renderStart[0] + radius)/fWidth,
            y: (renderStart[1] + radius)/fHeight
        )
        
        let gradientLayer = _fillLayer as! CAGradientLayer
        gradientLayer.type = .radial
        gradientLayer.startPoint = center
        gradientLayer.endPoint = to
        gradientLayer.colors = _gradientColors
        gradientLayer.locations = _gradientLocations as [NSNumber]?
        on.addSublayer(_fillLayer)
    }
}
