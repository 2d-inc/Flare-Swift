//
//  flare_sk_artboard.swift
//  FlareSkia
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public class FlareSkArtboard: ActorArtboard {
    public init(actor: FlareSkActor) {
        super.init(actor: actor)
    }
    
    override public func advance(seconds: Double) {
        super.advance(seconds: seconds)
    }
    
    override public func makeInstance() -> ActorArtboard {
        let artboardInstance = FlareSkArtboard(actor: actor as! FlareSkActor)
        artboardInstance.copyArtboard(self)
        return artboardInstance
    }
    
    public func draw(skCanvas: OpaquePointer) {
        for drawable in drawableNodes {
            if let d = drawable as? FlareSkDrawable {
                d.draw(skCanvas)
            }
        }
    }
    
    func dispose() {}
}
