//
//  segment_bezier.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 3/8/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

/// This is a parametric segment between two p0 and p1
class Segment: Bezier {
    var points: [Vec2D]
    var order: Int {
        return 1
    }
    
    init(_ points: [Vec2D]){
        if (points.count != 2) {
            fatalError("Segment require exactly two points")
        }
        self.points = points
    }
    
    func pointAt(_ t: Float) -> Vec2D {
        let mt = 1-t
        let x1 = startPoint[0]
        let y1 = startPoint[1]
        let x2 = endPoint[0]
        let y2 = endPoint[1]
        let point = Vec2D.init(fromValues: t*x1 + mt*x2, t*y1 + mt*y2)
        return point
    }
    
    func derivativeAt(_ t: Float, _ cachedFirstOrderDerivativePoints: [Vec2D]?) -> Vec2D {
        let xd = startPoint[0] - endPoint[0]
        let yd = startPoint[1] - endPoint[1]
        
        return Vec2D.init(fromValues: xd, yd)
    }
    
    public var description : String { return "Segment: ([\(points[0].description), \(points[1].description)" }
}
