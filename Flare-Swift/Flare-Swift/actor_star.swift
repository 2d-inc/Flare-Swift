//
//  actor_star.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/20/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class ActorStar: ActorProceduralPath {
    var _numPoints = 5
    var _innerRadius = 0.0
    
    override func invalidatePath() {}
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let star = ActorStar()
        star.copyStar(self, resetArtboard)
        return star
    }
    
    private func copyStar(_ node: ActorStar, _ ab: ActorArtboard) {
        copyPath(node, ab)
        _numPoints = node._numPoints
        _innerRadius = node._innerRadius
    }
    
    static func read(_ artboard: ActorArtboard, _ reader: StreamReader, _ component: inout ActorStar?) -> ActorStar {
        if component == nil {
            component = ActorStar()
        }
        _ = ActorNode.read(artboard, reader, component!)
        component!.width = Double(reader.readFloat32(label: "width"))
        component!.height = Double(reader.readFloat32(label: "height"))
        component!._numPoints = Int(reader.readUint32(label: "points"))
        component!._innerRadius = Double(reader.readFloat32(label: "innerRadius"))
        return component!
    }
    
    override var points: [PathPoint] {
        let fry = Float32(radiusY)
        let frx = Float32(radiusX)
        
        var _starPoints = [
            StraightPathPoint.init(fromTranslation: Vec2D.init(fromValues: 0.0, y: -fry))
        ]
        var angle = -Float.pi / 2.0
        let inc = (Float.pi * 2.0) / Float32(sides)
        let sx = Vec2D.init(fromValues: frx, y: frx * Float32(_innerRadius))
        let sy = Vec2D.init(fromValues: fry, y: fry * Float32(_innerRadius))
        
        for i in 0 ..< sides {
            _starPoints.append(
                StraightPathPoint.init(fromTranslation: Vec2D.init(fromValues: cos(angle) * sx[i % 2], y: sin(angle) * sy[i % 2]))
            )
            angle += inc
        }
        
        return _starPoints
    }
    
    var innerRadius: Double {
        get {
            return _innerRadius
        }
        set {
            if newValue != _innerRadius {
                _innerRadius = newValue
                markPathDirty()
            }
        }
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
    var numPoints: Int {
        return _numPoints
    }
    var sides: Int {
        return numPoints * 2
    }
}
