//
//  cubic_bezier.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 3/7/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

/// Concrete class of cubic Bézier curves.
class CubicBezier: Bezier {    
    var points: [Vec2D]
    /// Constructs a cubic Bézier curve from a [List] of [Vector2].  The first point
    /// in [points] will be the curve's start point, the second and third points will
    /// be its control points, and the fourth point will be its end point.
    init(_ points: [Vec2D]) {
        if (points.count != 4) {
            fatalError("Cubic Bézier curves require exactly four points")
        }
        self.points = points
    }
    
    var order: Int { return 3 }
    
    func pointAt(_ t: Float) -> Vec2D {
        let t2 = t * t;
        let mt = 1.0 - t;
        let mt2 = mt * mt;
        
        let a = mt2 * mt;
        let b = mt2 * t * 3;
        let c = mt * t2 * 3;
        let d = t * t2;
        
        let point = Vec2D.init(clone: startPoint)
        _ = Vec2D.scale(point, point, a)
        _ = Vec2D.scaleAndAdd(point, point, points[1], b)
        _ = Vec2D.scaleAndAdd(point, point, points[2], c)
        _ = Vec2D.scaleAndAdd(point, point, points[3], d)
        
        return point;
    }
    
    func derivativeAt(_ t: Float, _ cachedFirstOrderDerivativePoints: [Vec2D]?) -> Vec2D {
        let derivativePoints = cachedFirstOrderDerivativePoints ?? firstOrderDerivativePoints;
        let mt = 1.0 - t;
        let a = mt * mt;
        let b = 2.0 * mt * t;
        let c = t * t;
        
        let localDerivative = Vec2D.init(clone: derivativePoints[0])
        _ = Vec2D.scale(localDerivative, localDerivative, a)
        _ = Vec2D.scaleAndAdd(localDerivative, localDerivative, derivativePoints[1], b)
        _ = Vec2D.scaleAndAdd(localDerivative, localDerivative, derivativePoints[2], c)

        return localDerivative;
    }
    
    public var description: String { return "CubicBezier([\(points[0].description), \(points[1].description), \(points[2].description), \(points[3].description)])" }

}
