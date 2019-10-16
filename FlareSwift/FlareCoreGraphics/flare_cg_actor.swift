//
//  flare_cg_actor.swift
//  FlareCoreGraphics
//
//  Created by Umberto Sonnino on 2/22/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import MetalKit

public class FlareCGActor: Actor {
    public var maxTextureIndex: Int = 0
    public var _version: Int = -1
    public var _artboardCount: Int = 0
    public var images: [Data]?
    public var _artboards: [ActorArtboard?] = []
    
    public var artboard: FlareCGArtboard? {
        return _artboards.count > 0 ? (_artboards.first as! FlareCGArtboard) : nil
    }
    required public init() {}
    
    public func makeArtboard() -> ActorArtboard {
        return FlareCGArtboard(actor: self)
    }
    
    public func makeShapeNode() -> ActorShape {
        return FlareCGShape()
    }
    
    public func makePathNode() -> ActorPath {
        return FlareCGActorPath()
    }
    
    public func makeRectangle() -> ActorRectangle {
        return FlareCGRectangle()
    }
    
    public func makeTriangle() -> ActorTriangle {
        return FlareCGTriangle()
    }
    
    public func makeStar() -> ActorStar {
        return FlareCGStar()
    }
    
    public func makePolygon() -> ActorPolygon {
        return FlareCGPolygon()
    }
    
    public func makeEllipse() -> ActorEllipse {
        return FlareCGEllipse()
    }

    public func makeColorFill() -> ColorFill {
        return FlareCGColorFill()
    }

    public func makeColorStroke() -> ColorStroke {
        return FlareCGColorStroke()
    }

    public func makeGradientFill() -> GradientFill {
        return FlareCGGradientFill()
    }

    public func makeGradientStroke() -> GradientStroke {
        return FlareCGGradientStroke()
    }

    public func makeRadialFill() -> RadialGradientFill {
        return FlareCGRadialFill()
    }

    public func makeRadialStroke() -> RadialGradientStroke {
        return FlareCGRadialStroke()
    }
    
    public func makeImageNode() -> ActorImage {
        return ActorImage()
    }
    
    func loadData(_ data: Data) {
        self.load(data: data)
    }
    
    public func dispose(){}
    public func onImageData(_ rawData: [Data]) {}
    
    public func loadFromBundle(filename: String) -> Bool {
        let endIndex = filename.index(filename.endIndex, offsetBy: -4)
        let fname = String(filename.prefix(upTo: endIndex))
        if let path = Bundle.main.path(forResource: fname, ofType: "flr") {
            if let data = FileManager.default.contents(atPath: path) {
                self.load(data: data)
                return true
            }
        }
        return false
    }
}
