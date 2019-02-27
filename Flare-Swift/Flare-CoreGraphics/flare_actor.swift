//
//  flare_actor.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/22/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class FlareActor: Actor {
    var maxTextureIndex: Int = 0
    var _version: Int = -1
    var _artboardCount: Int = 0
    var _artboards: [ActorArtboard?] = []

    func makeImageNode() -> ActorImage {
        return ActorImage()
    }

    func makeColorFill() -> ColorFill {
        return ColorFill()
    }

    func makeColorStroke() -> ColorStroke {
        return ColorStroke()
    }

    func makeGradientFill() -> GradientFill {
        return GradientFill()
    }

    func makeGradientStroke() -> GradientStroke {
        return GradientStroke()
    }

    func makeRadialFill() -> RadialGradientFill {
        return RadialGradientFill()
    }

    func makeRadialStroke() -> RadialGradientStroke {
        return RadialGradientStroke()
    }
    
    func loadData(_ data: Data) {
        self.load(data: data)
    }
}
