//
//  quadratic_bezier.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 3/7/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class QuadraticBezier: Bezier {
    var points: [Vec2D]
    var order: Int {
        return 2
    }
    
    init(_ points: [Vec2D]){
        if (points.count != 3) {
            fatalError("Quadratic Bézier curves require exactly three points")
        }
        self.points = points
    }
    
    func pointAt(_ t: Float) -> Vec2D {
        let t2 = t * t;
        let mt = 1.0 - t;
        let mt2 = mt * mt;
        
        let a = mt2;
        let b = 2.0 * mt * t;
        let c = t2;
        
        let point = Vec2D.init(clone: startPoint)
        _ = Vec2D.scale(point, point, a)
        _ = Vec2D.scaleAndAdd(point, point, points[1], b)
        _ = Vec2D.scaleAndAdd(point, point, points[2], c)
        
        return point
    }
    
    func derivativeAt(_ t: Float, _ cachedFirstOrderDerivativePoints: [Vec2D]?) -> Vec2D {
        let derivativePoints = cachedFirstOrderDerivativePoints ?? self.firstOrderDerivativePoints
        let result = Vec2D()
        Vec2D.mix(result, derivativePoints[0], derivativePoints[1], t);
        return result;
    }
    
    /// Returns a [CubicBezier] instance with the same start and end points as [this]
    /// and control points positioned so it produces identical points along the
    /// curve as [this].
    func toCubicBezier() -> CubicBezier {
        var cubicCurvePoints = [Vec2D]()
        cubicCurvePoints.append(startPoint)
        
        let pointsCount = points.count
        
        for index in 1 ..< pointsCount {
            let currentPoint = points[index];
            let previousPoint = points[index - 1];
            let raisedPoint = Vec2D()
            _ = Vec2D.scaleAndAdd(raisedPoint, raisedPoint, currentPoint, Float((pointsCount - index) / pointsCount))
            _ = Vec2D.scaleAndAdd(raisedPoint, raisedPoint, previousPoint, Float(index/pointsCount))
            
            cubicCurvePoints.append(raisedPoint);
        }
        
        cubicCurvePoints.append(endPoint);
        
        return CubicBezier(cubicCurvePoints);
    }
    
    public var description : String { return "BDQuadraticBezier([\(points[0].description), \(points[1].description), \(points[2].description)])" }
}
