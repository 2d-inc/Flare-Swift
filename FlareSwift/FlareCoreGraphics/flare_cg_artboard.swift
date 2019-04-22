//
//  flare_cg_artboard.swift
//  FlareCoreGraphics
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public class FlareCGArtboard: ActorArtboard {
    public init(actor: FlareCGActor) {
        super.init(actor: actor)
    }
    
    override public func advance(seconds: Double) {
        super.advance(seconds: seconds)
    }
    
    override public func makeInstance() -> ActorArtboard {
        let artboardInstance = FlareCGArtboard(actor: actor as! FlareCGActor)
        artboardInstance.copyArtboard(self)
        return artboardInstance
    }
    
    public func draw(context: CGContext, on layer: CALayer) {
        // Cleanup.
        if let sublayers = layer.sublayers {
            for sublayer in sublayers {
                sublayer.removeFromSuperlayer()
            }
        }
        for drawable in drawableNodes {
            if let d = drawable as? FlareCGDrawable {
                d.draw(context: context, on: layer)
            }
        }
    }
    
    func dispose() {}
}
