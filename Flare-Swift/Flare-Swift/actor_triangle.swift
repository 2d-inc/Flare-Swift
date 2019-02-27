//
//  actor_triangle.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/20/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class ActorTriangle: ActorProceduralPath {
    override func invalidatePath() {}
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let triangle = ActorTriangle()
        triangle.copyPath(self, resetArtboard)
        return triangle
    }
    
    func readTriangle(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readNode(artboard, reader)
        self.width = Double(reader.readFloat32(label: "width"))
        self.height = Double(reader.readFloat32(label: "height"))
    }
    
    override var points: [PathPoint] {
        var _trianglePoints = [PathPoint]()
        let frx = Float32(self.radiusX)
        let fry = Float32(self.radiusY)
        _trianglePoints.append(StraightPathPoint.init(fromTranslation: Vec2D.init(fromValues: 0.0, y: -fry)))
        _trianglePoints.append(StraightPathPoint.init(fromTranslation: Vec2D.init(fromValues: frx, y: fry)))
        _trianglePoints.append(StraightPathPoint.init(fromTranslation: Vec2D.init(fromValues: -frx, y: fry)))
        return _trianglePoints
    }
    
    var isClosed: Bool {
        return true
    }
    var doesDraw: Bool {
        return !self.renderCollapsed
    }
    var radiusX: Double {
        return self.width/2
    }
    var radiusY: Double {
        return self.height/2
    }
}
