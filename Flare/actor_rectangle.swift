//
//  actor_rectangle.swift
//  Flare
//
//  Created by Umberto Sonnino on 2/20/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public class ActorRectangle: ActorProceduralPath {
    var _radius = 0.0
    
    override public var isClosed: Bool { return true }
    var doesDraw: Bool { return !self.renderCollapsed }
    var radius: Double {
        get { return _radius }
        set {
            if newValue != _radius {
                _radius = newValue
                invalidateDrawable()
            }
        }
    }
    
    override public var points: [PathPoint] {
        let hw = Float32(self._width/2)
        let hh = Float32(self._height/2)
        let minH = Float32(min(hw, hh))
        let renderRadius = min(_radius, Double(minH))
        
        return [
            StraightPathPoint.init(fromValues: Vec2D(fromValues: -hw, -hh), renderRadius),
            StraightPathPoint.init(fromValues: Vec2D(fromValues: hw, -hh), renderRadius),
            StraightPathPoint.init(fromValues: Vec2D(fromValues: hw, hh), renderRadius),
            StraightPathPoint.init(fromValues: Vec2D(fromValues: -hw, hh), renderRadius),
        ]   
    }
    
    override public func invalidatePath() {}
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let rectangle = ActorRectangle()
        rectangle.copyRectangle(self, resetArtboard)
        return rectangle
    }
    
    func copyRectangle(_ node: ActorRectangle, _ ab: ActorArtboard) {
        copyPath(node, ab)
        _radius = node._radius
    }
    
    func readRectangle(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readNode(artboard, reader)
        self.width = Double(reader.readFloat32(label: "width"))
        self.height = Double(reader.readFloat32(label: "height"))
        self._radius = Double(reader.readFloat32(label: "cornerRadius"))
    }
}
