//
//  actor_rectangle.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/20/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public class ActorRectangle: ActorProceduralPath {
    var _radius = 0.0
    
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
//        _ = ActorNode.read(artboard, reader, component!)
        self.readNode(artboard, reader)
        self.width = Double(reader.readFloat32(label: "width"))
        self.height = Double(reader.readFloat32(label: "height"))
        self._radius = Double(reader.readFloat32(label: "cornerRadius"))
    }
    
    override public var points: [PathPoint] {
        let hw = Float32(self._width/2)
        let hh = Float32(self._height/2)
        
        return [
            StraightPathPoint.init(fromValues: Vec2D(fromValues: -hw, -hh), _radius),
            StraightPathPoint.init(fromValues: Vec2D(fromValues: hw, -hh), _radius),
            StraightPathPoint.init(fromValues: Vec2D(fromValues: hw, hh), _radius),
            StraightPathPoint.init(fromValues: Vec2D(fromValues: -hw, hh), _radius),
        ]
        
    }
    
    var isClosed: Bool {
        return true
    }
    var doesDraw: Bool {
        return !self.renderCollapsed
    }
    var radius: Double {
        get {
            return _radius
        }
        set {
            if newValue != _radius {
                _radius = newValue
                invalidateDrawable()
            }
        }
    }
}
