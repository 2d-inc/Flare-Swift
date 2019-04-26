//
//  flare_cg_color_fill.swift
//  FlareCoreGraphics
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class FlareCGColorFill: ColorFill, FlareCGFill {
    var _fillLayer: CALayer = CAShapeLayer()
    var _fillColor = CGColor.black
    
    var uiColor: CGColor {
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
    
    override func initializeGraphics() {
        _fillColor = self.uiColor
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceFill = FlareCGColorFill()
        instanceFill.copyColorFill(self, resetArtboard)
        return instanceFill
    }
    
    override func update(dirt: UInt8) {
        super.update(dirt: dirt)
        _fillColor = self.uiColor
    }
    
    func paint(fill: ActorFill, on: CALayer, path: CGPath) {
        let onBounds = on.bounds
        let layerFrame = CGRect(x: 0, y: 0, width: onBounds.width, height: onBounds.height)
        
        if !_fillLayer.frame.equalTo(layerFrame) {
            _fillLayer.frame = layerFrame
        }
        
        let fillLayer = _fillLayer as! CAShapeLayer
        fillLayer.path = path
        fillLayer.fillColor = self._fillColor
        fillLayer.fillRule = self.fillRule
        on.addSublayer(_fillLayer)
    }
}
