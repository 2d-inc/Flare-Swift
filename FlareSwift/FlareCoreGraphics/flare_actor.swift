//
//  flare_actor.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/22/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public class FlareActor: Actor {
    public var maxTextureIndex: Int = 0
    public var _version: Int = -1
    public var _artboardCount: Int = 0
    public var _artboards: [ActorArtboard?] = []
    public var artboard: FlareArtboard? {
        return _artboards.count > 0 ? (_artboards.first as! FlareArtboard) : nil
    }
    
    public init() {}
    
    public func makeArtboard() -> ActorArtboard {
        return FlareArtboard(actor: self)
    }
    
    public func makeShapeNode() -> ActorShape {
        return FlareShape()
    }
    
    public func makePathNode() -> ActorPath {
        return FlareActorPath()
    }
    
    public func makeRectangle() -> ActorRectangle {
        return FlareRectangle()
    }
    
    public func makeTriangle() -> ActorTriangle {
        return FlareTriangle()
    }
    
    public func makeStar() -> ActorStar {
        return FlareStar()
    }
    
    public func makePolygon() -> ActorPolygon {
        return FlarePolygon()
    }
    
    public func makeEllipse() -> ActorEllipse {
        return FlareEllipse()
    }

    public func makeColorFill() -> ColorFill {
        return FlareColorFill()
    }

    public func makeColorStroke() -> ColorStroke {
        return FlareColorStroke()
    }

    public func makeGradientFill() -> GradientFill {
        return FlareGradientFill()
    }

    public func makeGradientStroke() -> GradientStroke {
        return FlareGradientStroke()
    }

    public func makeRadialFill() -> RadialGradientFill {
        return FlareRadialFill()
    }

    public func makeRadialStroke() -> RadialGradientStroke {
        return FlareRadialStroke()
    }
    
    func loadData(_ data: Data) {
        self.load(data: data)
    }
}
