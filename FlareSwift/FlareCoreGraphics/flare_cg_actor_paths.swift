//
//  flare_cg_actor_paths.swift
//  FlareCoreGraphics
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class FlareCGActorPath: ActorPath, FlareCGPath {
    var isClosed: Bool {
        return _isClosed
    }
    var _path: CGMutablePath = CGMutablePath()
    var _isValid: Bool = false
    
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgPath = FlareCGActorPath()
        cgPath.copyPath(self, resetArtboard)
        return cgPath
    }
}

class FlareCGEllipse: ActorEllipse, FlareCGPath {
    var _path: CGMutablePath = CGMutablePath()
    var _isValid: Bool = false
    var deformedPoints: [PathPoint]? {
        return points
    }
    
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgEllipse = FlareCGEllipse()
        cgEllipse.copyPath(self, resetArtboard)
        return cgEllipse
    }
}

class FlareCGTriangle: ActorTriangle, FlareCGPath {
    var _path: CGMutablePath = CGMutablePath()
    var _isValid: Bool = false
    var deformedPoints: [PathPoint]? {
        return points
    }
    
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgTriangle = FlareCGTriangle()
        cgTriangle.copyPath(self, resetArtboard)
        return cgTriangle
    }
}

class FlareCGRectangle: ActorRectangle, FlareCGPath {
    var _path: CGMutablePath = CGMutablePath()
    var _isValid: Bool = false
    var deformedPoints: [PathPoint]? {
        return points
    }
    
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgRectangle = FlareCGRectangle()
        cgRectangle.copyRectangle(self, resetArtboard)
        return cgRectangle
    }
}

class FlareCGStar: ActorStar, FlareCGPath {
    var _path: CGMutablePath = CGMutablePath()
    var _isValid: Bool = false
    var deformedPoints: [PathPoint]? {
        return points
    }
 
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgStar = FlareCGStar()
        cgStar.copyStar(self, resetArtboard)
        return cgStar
    }
}

class FlareCGPolygon: ActorPolygon, FlareCGPath {
    var _path: CGMutablePath = CGMutablePath()
    var _isValid: Bool = false
    var deformedPoints: [PathPoint]? {
        return points
    }
    
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let cgPolygon = FlareCGPolygon()
        cgPolygon.copyPolygon(self, resetArtboard)
        return cgPolygon
    }
}
