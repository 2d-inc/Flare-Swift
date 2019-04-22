//
//  flare_cg_artboard.swift
//  FlareCoreGraphics
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public class FlareCGArtboard: ActorArtboard {
    private let artboardLayer = CALayer()
    private var container = CGRect()
    private var setupAABB: AABB!
    
    public init(actor: FlareCGActor) {
        super.init(actor: actor)
        artboardLayer.masksToBounds = clipContents
    }
    
    var rect: CGRect {
        get {
            return artboardLayer.bounds
        }
        set {
            if !container.equalTo(newValue) {
                container = newValue
                let contentWidth = CGFloat(setupAABB[2] - setupAABB[0])
                let contentHeight = CGFloat(setupAABB[3] - setupAABB[1])
                
                // Contain.
                let scaleX = newValue.width / contentWidth
                let scaleY = newValue.height / contentHeight
                let scale = min(scaleX, scaleY)
                
                artboardLayer.anchorPoint = CGPoint(x: 0, y: 0)
                artboardLayer.frame = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
// TODO: translate too.
//              let x = contentWidth * CGFloat(artboard.origin.x)
//              let y = contentHeight * CGFloat(artboard.origin.y)
//              ctx.translateBy(x: x, y: y)
                artboardLayer.transform = CATransform3DMakeScale(scale, scale, 1)
                artboardLayer.backgroundColor = CGColor.cgColor(red: 93/255, green: 93/255, blue: 93/255, alpha: 1)
            }
        }
    }
    
    override public func advance(seconds: Double) {
        super.advance(seconds: seconds)
    }
    
    override public func makeInstance() -> ActorArtboard {
        let artboardInstance = FlareCGArtboard(actor: actor as! FlareCGActor)
        artboardInstance.copyArtboard(self)
        return artboardInstance
    }
    
    func updateBounds() {
        setupAABB = artboardAABB()
    }
    
    func initializeGraphics(_ layer: CALayer) {
        layer.addSublayer(artboardLayer)
        super.initializeGraphics()
        for drawable in drawableNodes {
            if let cgDrawable = drawable as? FlareCGDrawable {
                artboardLayer.addSublayer(cgDrawable._layer)
            }
        }
    }

    public func draw() {
        for drawable in drawableNodes {
            if let d = drawable as? FlareCGDrawable {
                d.draw(on: artboardLayer)
            }
        }
    }
    
    func dispose() {}
}
