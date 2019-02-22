//
//  actor_rectangle.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/20/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class ActorRectangle: ActorProceduralPath {
    var _radius = 0.0
    
    override func invalidatePath() {}
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let rectangle = ActorRectangle()
        rectangle.copyRectangle(self, resetArtboard)
        return rectangle
    }
    
    private func copyRectangle(_ node: ActorRectangle, _ ab: ActorArtboard) {
        copyPath(node, ab)
        _radius = node._radius
    }
    
    static func read(_ artboard: ActorArtboard, _ reader: StreamReader, _ component: inout ActorRectangle?) -> ActorRectangle {
        if component == nil {
            component = ActorRectangle()
        }
        
        _ = ActorNode.read(artboard, reader, component!)
        component!.width = Double(reader.readFloat32(label: "width"))
        component!.height = Double(reader.readFloat32(label: "height"))
        component!._radius = Double(reader.readFloat32(label: "cornerRadius"))
        return component!
    }
    
    override var points: [PathPoint] {
        let hw = Float32(self._width)
        let hh = Float32(self._height)
        
        return [
            StraightPathPoint.init(fromValues: Vec2D(fromValues: -hw, y: -hh), _radius),
            StraightPathPoint.init(fromValues: Vec2D(fromValues: hw, y: -hh), _radius),
            StraightPathPoint.init(fromValues: Vec2D(fromValues: hw, y: hh), _radius),
            StraightPathPoint.init(fromValues: Vec2D(fromValues: -hw, y: hh), _radius),
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
                markPathDirty()
            }
        }
    }
}
