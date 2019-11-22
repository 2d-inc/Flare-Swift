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
    var _gradient: CGGradient!
    private let _colorSpace = CGColorSpaceCreateDeviceRGB()
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceGradientFill = FlareCGGradientFill()
        instanceGradientFill.copyGradientFill(self, resetArtboard)
        return instanceGradientFill
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
        let startPoint = CGPoint(x: renderStart[0], y: renderStart[1])
        let endPoint = CGPoint(x: renderEnd[0], y: renderEnd[1])

        context.addPath(path)
        context.setFillColor(_fillColor)
        context.clip()
        context.drawLinearGradient(_gradient, start: startPoint, end: endPoint, options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
    }
}
