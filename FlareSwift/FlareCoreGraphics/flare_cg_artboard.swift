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
                let contentWidth = setupAABB[2] - setupAABB[0]
                let contentHeight = setupAABB[3] - setupAABB[1]
                
                // Contain.
                let scaleX = newValue.width / CGFloat(contentWidth)
                let scaleY = newValue.height / CGFloat(contentHeight)
                let scale = min(scaleX, scaleY)
                
                artboardLayer.anchorPoint = CGPoint(x: 0, y: 0)
                artboardLayer.frame = CGRect(x: 0, y: 0, width: CGFloat(contentWidth), height: CGFloat(contentHeight))
                artboardLayer.transform = CATransform3DMakeScale(scale, scale, 1)
                artboardLayer.bounds.origin = CGPoint(x: origin.x*contentWidth, y: origin.y*contentHeight)
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
                cgDrawable.addLayer(on: artboardLayer)
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
