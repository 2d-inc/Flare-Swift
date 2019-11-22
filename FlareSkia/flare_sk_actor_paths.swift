//
//  flare_sk_actor_paths.swift
//  FlareSkia
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import Skia

class FlareSkActorPath: ActorPath, FlareSkPathPointsPath {
    var _path: OpaquePointer = sk_path_new()
    var _isValid: Bool = false
    
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let path = FlareSkActorPath()
        path.copyPath(self, resetArtboard)
        return path
    }
}

class FlareSkEllipse: ActorEllipse, FlareSkPathPointsPath {
    var _path: OpaquePointer = sk_path_new()
    var _isValid: Bool = false

    
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let ellipse = FlareSkEllipse()
        ellipse.copyPath(self, resetArtboard)
        return ellipse
    }
}

class FlareSkTriangle: ActorTriangle, FlareSkPathPointsPath {
    var _path: OpaquePointer = sk_path_new()
    var _isValid: Bool = false

    
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let triangle = FlareSkTriangle()
        triangle.copyPath(self, resetArtboard)
        return triangle
    }
}

class FlareSkRectangle: ActorRectangle, FlareSkPathPointsPath {
    var _path: OpaquePointer = sk_path_new()
    var _isValid: Bool = false

    
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let rectangle = FlareSkRectangle()
        rectangle.copyRectangle(self, resetArtboard)
        return rectangle
    }
}

class FlareSkStar: ActorStar, FlareSkPathPointsPath {
    var _path: OpaquePointer = sk_path_new()
    var _isValid: Bool = false

 
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let star = FlareSkStar()
        star.copyStar(self, resetArtboard)
        return star
    }
}

class FlareSkPolygon: ActorPolygon, FlareSkPathPointsPath {
    var _path: OpaquePointer = sk_path_new()
    var _isValid: Bool = false

    
    override func invalidatePath() {
        _isValid = false
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let polygon = FlareSkPolygon()
        polygon.copyPolygon(self, resetArtboard)
        return polygon
    }
}
