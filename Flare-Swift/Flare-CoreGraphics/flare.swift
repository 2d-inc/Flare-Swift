//
//  flare.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/22/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class CoreGraphicsActor: Actor {
    var maxTextureIndex: Int = 0
    var _version: Int = -1
    var _artboardCount: Int = 0
    var _artboards: [ActorArtboard?] = []
    
    func makeImageNode() -> ActorImage {
        <#code#>
    }
    
    func makeColorFill() -> ColorFill {
        <#code#>
    }
    
    func makeColorStroke() -> ColorStroke {
        <#code#>
    }
    
    func makeGradientFill() -> GradientFill {
        <#code#>
    }
    
    func makeGradientStroke() -> GradientStroke {
        <#code#>
    }
    
    func makeRadialFill() -> RadialGradientFill {
        <#code#>
    }
    
    func makeRadialStroke() -> RadialGradientStroke {
        <#code#>
    }
}
