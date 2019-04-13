//
//  actor_polygon.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/20/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public class ActorPolygon: ActorProceduralPath {
    var sides = 5
    
    override public func invalidatePath() {}
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let polygon = ActorPolygon()
        polygon.copyPolygon(self, resetArtboard)
        return polygon
    }
    
    func copyPolygon(_ node: ActorPolygon, _ ab: ActorArtboard) {
        copyPath(node, ab)
        sides = node.sides
    }
    
    func readPolygon(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readNode(artboard, reader)
        self.width = Double(reader.readFloat32(label: "width"))
        self.height = Double(reader.readFloat32(label: "height"))
        self.sides = Int(reader.readUint32(label: "sides"))
    }
    
    override public var points: [PathPoint] {
        var _polygonPoints = [PathPoint]()
        var angle = Float32.pi / 2.0
        let inc = (Float32.pi * 2.0) / Float32(sides)
        let frx = Float32(self.radiusX)
        let fry = Float32(self.radiusY)
        
        for _ in 0 ..< sides {
            _polygonPoints.append(
                StraightPathPoint.init(fromTranslation: Vec2D.init(fromValues: cos(angle) * frx, sin(angle) * fry))
            )
            angle += inc
        }

        return _polygonPoints
    }
    
    override public var isClosed: Bool {
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
