//
//  flare_cg_gradient_stroke.swift
//  FlareCoreGraphics
//
//  Created by Umberto Sonnino on 3/4/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class FlareCGGradientStroke: GradientStroke, FlareCGStroke {
    var _color: CGColor = CGColor.black
    var _strokeCap: CAShapeLayerLineCap = .butt
    var _strokeJoin: CAShapeLayerLineJoin = .miter
    var _strokeWidth: CGFloat = 0.0
    var effectPath: CGPath? = nil
    
    var _gradientColors: [CGColor]!
    var _gradientLocations: [NSNumber]!
    
    var _strokeLayer: CALayer = CAGradientLayer()
    let strokeMask = CAShapeLayer()

    override func markPathEffectsDirty() {
        effectPath = nil
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceGradientStroke = FlareCGGradientStroke()
        instanceGradientStroke.copyGradientStroke(self, resetArtboard)
        return instanceGradientStroke
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
        _strokeWidth = CGFloat(width)
    }
    
    func paint(stroke: ActorStroke, on: CALayer, path: CGPath) {
        let bounds = on.bounds
        let width = Float(bounds.width)
        let height = Float(bounds.height)
        let startPoint = CGPoint(x: renderStart[0]/width, y: renderStart[1]/height)
        let endPoint = CGPoint(x: renderEnd[0]/width, y: renderEnd[1]/height)

        // Remove fill color and just stroke this layer.
        strokeMask.fillColor = CGColor.clear
        strokeMask.path = path
        strokeMask.strokeColor = _color
        strokeMask.lineWidth = _strokeWidth
        strokeMask.lineJoin = strokeJoin
        
        let strokeLayer = _strokeLayer as! CAGradientLayer
        // Mask the gradient with the Stroke layer that we just defined above.
        // This'll draw only the portion of the screen described by the stroked path.
        strokeLayer.startPoint = startPoint
        strokeLayer.endPoint = endPoint
        strokeLayer.colors = _gradientColors
        strokeLayer.locations = _gradientLocations
        strokeLayer.frame = on.frame
        strokeLayer.mask = strokeMask
        
        on.addSublayer(strokeLayer)
    }
    
    
}
