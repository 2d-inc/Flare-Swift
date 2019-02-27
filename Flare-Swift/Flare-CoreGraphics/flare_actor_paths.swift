//
//  flare_actor_paths.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class FlareActorPath: ActorPath, FlarePath {
    var isClosed: Bool {
        return _isClosed
    }
    var _path: CGMutablePath = CGMutablePath()
    var _isValid: Bool = false
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgPath = FlareActorPath()
        cgPath.copyPath(self, resetArtboard)
        return cgPath
    }
}

class FlareActorEllipse: ActorEllipse, FlarePath {
    var _path: CGMutablePath = CGMutablePath()
    var _isValid: Bool = false
    var deformedPoints: [PathPoint]?
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgEllipse = FlareActorEllipse()
        cgEllipse.copyPath(self, resetArtboard)
        return cgEllipse
    }
}

class FlareActorTriangle: ActorTriangle, FlarePath {
    var _path: CGMutablePath = CGMutablePath()
    var _isValid: Bool = false
    var deformedPoints: [PathPoint]?
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgTriangle = FlareActorTriangle()
        cgTriangle.copyPath(self, resetArtboard)
        return cgTriangle
    }
}

class FlareActorRectangle: ActorRectangle, FlarePath {
    var _path: CGMutablePath = CGMutablePath()
    var _isValid: Bool = false
    var deformedPoints: [PathPoint]?
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgRectangle = FlareActorRectangle()
        cgRectangle.copyRectangle(self, resetArtboard)
        return cgRectangle
    }
}

class FlareActorStar: ActorStar, FlarePath {
    var _path: CGMutablePath = CGMutablePath()
    var _isValid: Bool = false
    var deformedPoints: [PathPoint]?
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgStar = FlareActorStar()
        cgStar.copyStar(self, resetArtboard)
        return cgStar
    }
}

class FlareActorPolygon: ActorPolygon, FlarePath {
    var _path: CGMutablePath = CGMutablePath()
    var _isValid: Bool = false
    var deformedPoints: [PathPoint]?
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgPolygon = FlareActorPolygon()
        cgPolygon.copyPolygon(self, resetArtboard)
        return cgPolygon
    }
}
