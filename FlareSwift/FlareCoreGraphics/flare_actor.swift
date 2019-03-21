//
//  flare_actor.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/22/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import MetalKit

public class FlareActor: Actor {
    public var maxTextureIndex: Int = 0
    public var _version: Int = -1
    public var _artboardCount: Int = 0
    public var images: [Data]?
    public var _artboards: [ActorArtboard?] = []
  
    var _metalController: MetalController! = nil
    
    public var artboard: FlareArtboard? {
        return _artboards.count > 0 ? (_artboards.first as! FlareArtboard) : nil
    }
    
    var metalController: MetalController {
        get {
            if _metalController == nil {
                _metalController = MetalController()
            }
            return _metalController
        }
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
    
    public func makeImageNode() -> ActorImage {
//        return FlareImage(device: device, textureLoader: textureLoader)
        return FlareImage(self.metalController)
    }
    
    func loadData(_ data: Data) {
        self.load(data: data)
    }
    
    public func dispose(){}
    
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
