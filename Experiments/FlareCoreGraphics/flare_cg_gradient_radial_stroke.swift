//
//  flare_cg_gradient_radial_stroke.swift
//  FlareCoreGraphics
//
//  Created by Umberto Sonnino on 3/5/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class FlareCGRadialStroke: RadialGradientStroke, FlareCGStroke {
    var _color: CGColor = CGColor.black
    var _strokeCap: CGLineCap = .butt
    var _strokeJoin: CGLineJoin = .miter
    var _strokeWidth: CGFloat = 0.0
    var effectPath: CGPath? = nil
    
    var _gradient: CGGradient!
    
    override func markPathEffectsDirty() {
        effectPath = nil
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let radialStrokeNode = FlareCGRadialStroke()
        radialStrokeNode.copyRadialStroke(self, resetArtboard)
        return radialStrokeNode
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
        
        var paintColor: CGColor
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
        
        _color = paintColor
        _gradient = CGGradient(colorSpace: CGColorSpaceCreateDeviceRGB(), colorComponents: colors, locations: locations, count: locations.count)
        _strokeWidth = CGFloat(width)
        
    }
    
    
    func paint(stroke: ActorStroke, context: CGContext, path: CGPath) {
        let radius = CGFloat(Vec2D.distance(renderStart, renderEnd))
        let center = CGPoint(x: renderStart[0], y: renderStart[1])
        
        context.addPath(path)
        context.setFillColor(_color)
        context.setLineWidth(_strokeWidth)
        context.setLineCap(strokeCap)
        context.setLineJoin(strokeJoin)
        context.replacePathWithStrokedPath()
        context.clip()
        context.drawRadialGradient(_gradient, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: radius, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    }
}
