//
//  actor_ellipse.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/20/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class ActorEllipse: ActorProceduralPath {
    let CircleConstant: Float32 = 0.55;
    override func invalidatePath() {}
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let ellipse = ActorEllipse()
        ellipse.copyPath(self, resetArtboard)
        return ellipse
    }
    
    static func read(_ artboard: ActorArtboard, _ reader: StreamReader, _ component: inout ActorEllipse?) -> ActorEllipse {
        if component == nil {
            component = ActorEllipse()
        }
        
        _ = ActorNode.read(artboard, reader, component!)
        component!.width = Double(reader.readFloat32(label: "width"))
        component!.height = Double(reader.readFloat32(label: "height"))
        return component!
    }
    
    override var points: [PathPoint] {
        let frx = Float32(self.radiusX)
        let fry = Float32(self.radiusY)
        return [
            CubicPathPoint.init(fromValues:
                Vec2D.init(fromValues: 0.0, y: -fry),
                Vec2D.init(fromValues: -frx * CircleConstant, y: -fry),
                Vec2D.init(fromValues: frx * CircleConstant, y: -fry)
            ),
            CubicPathPoint.init(fromValues:
                Vec2D.init(fromValues: frx, y: 0.0),
                Vec2D.init(fromValues: frx, y: CircleConstant * -fry),
                Vec2D.init(fromValues: frx, y: CircleConstant * fry)
            ),
            CubicPathPoint.init(fromValues:
                Vec2D.init(fromValues: 0.0, y: fry),
                Vec2D.init(fromValues: frx * CircleConstant, y: fry),
                Vec2D.init(fromValues: -frx * CircleConstant, y: fry)
            ),
            CubicPathPoint.init(fromValues:
                Vec2D.init(fromValues: -frx, y: 0.0),
                Vec2D.init(fromValues: -frx, y: fry * CircleConstant),
                Vec2D.init(fromValues: -frx, y: -fry * CircleConstant)
            )
        ]
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
