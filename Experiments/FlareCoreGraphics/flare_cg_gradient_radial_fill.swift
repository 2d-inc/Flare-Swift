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
    var _gradient: CGGradient!
    private let _colorSpace = CGColorSpaceCreateDeviceRGB()
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let radialNode = FlareCGRadialFill()
        radialNode.copyRadialFill(self, resetArtboard)
        return radialNode
    }
    
    override func update(dirt: UInt8) {
        super.update(dirt: dirt)

        let numStops = Int(round( Double(colorStops.count)/5 ))

        var colors = [CGFloat]()
        var locations = [CGFloat]()
        
        var idx = 0
        for _ in 0 ..< numStops {
            let r = CGFloat(colorStops[idx])
            colors.append(r)
            let g = CGFloat(colorStops[idx+1])
            colors.append(g)
            let b = CGFloat(colorStops[idx+2])
            colors.append(b)
            let a = CGFloat(colorStops[idx+3])
            colors.append(a)
            locations.append(CGFloat(colorStops[idx+4]))
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
        _gradient = CGGradient(colorSpace: _colorSpace, colorComponents: colors, locations: locations, count: locations.count)
    }
    
    func paint(fill: ActorFill, context: CGContext, path: CGPath) {
        let radius = CGFloat(Vec2D.distance(renderStart, renderEnd))
        let center = CGPoint(x: renderStart[0], y: renderStart[1])
        
        context.addPath(path)
        context.setFillColor(_fillColor)
        context.clip()
        context.drawRadialGradient(_gradient, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: radius, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    }
}
