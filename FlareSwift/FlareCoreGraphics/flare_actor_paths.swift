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
    
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgPath = FlareActorPath()
        cgPath.copyPath(self, resetArtboard)
        return cgPath
    }
}

class FlareEllipse: ActorEllipse, FlarePath {
    var _path: CGMutablePath = CGMutablePath()
    var _isValid: Bool = false
    var deformedPoints: [PathPoint]? {
        return points
    }
    
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgEllipse = FlareEllipse()
        cgEllipse.copyPath(self, resetArtboard)
        return cgEllipse
    }
}

class FlareTriangle: ActorTriangle, FlarePath {
    var _path: CGMutablePath = CGMutablePath()
    var _isValid: Bool = false
    var deformedPoints: [PathPoint]? {
        return points
    }
    
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgTriangle = FlareTriangle()
        cgTriangle.copyPath(self, resetArtboard)
        return cgTriangle
    }
}

class FlareRectangle: ActorRectangle, FlarePath {
    var _path: CGMutablePath = CGMutablePath()
    var _isValid: Bool = false
    var deformedPoints: [PathPoint]? {
        return points
    }
    
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgRectangle = FlareRectangle()
        cgRectangle.copyRectangle(self, resetArtboard)
        return cgRectangle
    }
}

class FlareStar: ActorStar, FlarePath {
    var _path: CGMutablePath = CGMutablePath()
    var _isValid: Bool = false
    var deformedPoints: [PathPoint]? {
        return points
    }
 
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgStar = FlareStar()
        cgStar.copyStar(self, resetArtboard)
        return cgStar
    }
}

class FlarePolygon: ActorPolygon, FlarePath {
    var _path: CGMutablePath = CGMutablePath()
    var _isValid: Bool = false
    var deformedPoints: [PathPoint]? {
        return points
    }
    
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgPolygon = FlarePolygon()
        cgPolygon.copyPolygon(self, resetArtboard)
        return cgPolygon
    }
}
