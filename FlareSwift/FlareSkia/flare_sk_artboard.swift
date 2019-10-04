//
//  flare_sk_artboard.swift
//  FlareSkia
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import Skia

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
        if(clipContents) {
            sk_canvas_save(skCanvas)
            let aabb = artboardAABB()
            var clipRect = sk_rect_t(left: aabb[0], top: aabb[1], right: aabb[2], bottom: aabb[3])
            sk_canvas_clip_rect(skCanvas, &clipRect)
        }
        for drawable in drawableNodes {
            if let d = drawable as? FlareSkDrawable {
                d.draw(skCanvas)
            }
        }

        if (clipContents) {
            sk_canvas_restore(skCanvas)
        }
    }
    
    func dispose() {}
}
