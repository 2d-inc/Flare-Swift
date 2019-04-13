//
//  piecewise_bezier.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 4/12/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
/**
 This protocol allows the `PiecewiseBeizer` to be generic, and to extract
 subpaths independently of our renderer.
*/
protocol ConcretePath {
    init()
    func moveTo(_ to: Vec2D)
    func lineTo(_ to: Vec2D)
    func curveTo(_ to: Vec2D, control1: Vec2D, control2: Vec2D)
    func addPath(_ subpath: ConcretePath, mat: Mat2D)
}

class PiecewiseBezier<C> where C: ConcretePath {
    let curves: [Bezier]
    var transform = Mat2D()
    
    init(_ c: [Bezier]) {
        self.curves = c
    }
    
    var length: Float {
        var totalLength: Float = 0.0
        for curve in curves {
            totalLength += curve.length
        }
        
        return totalLength
    }
    
    func extractPath(_ start: Float, _ end: Float) -> ConcretePath? {
        let pLength = self.length
        var pStart = start
        var pEnd = end
        
        if pStart < 0 {
            pStart = 0
        }
        if pEnd > pLength {
            pEnd = pLength
        }
        
        guard self.curves.count > 0, pStart <= pEnd else {
            return nil
        }
        
        // Normalize.
        pStart /= pLength
        pEnd /= pLength
        
        let result = C.init()
        
        let btwn = self.between(startT: pStart, endT: pEnd)
        let beziers = btwn.curves
        
        if beziers.isEmpty {
            return result
        }
        
        let firstPoint = beziers.first!.points.first!
        result.moveTo(firstPoint)
        
        for c in beziers {
            if c is Segment {
                let nextPoint = c.points[1]
                result.lineTo(nextPoint)
            } else {
                let c1 = c.points[1]
                let c2 = c.points[2]
                let nextPoint = c.points[3]
                result.curveTo(nextPoint, control1: c1, control2: c2)
            }
        }
        
        return result
    }
    
    func between(startT: Float, endT: Float) -> PiecewiseBezier {
        let start = _piecewiseAt(t: startT, isStart: true)
        let end = _piecewiseAt(t: endT, isStart: false)
        
        var beziers = [Bezier]()
        
        if start.index != end.index {
            //            print("ADDING: \(start.curve.description)")
            beziers.append(start.curve)
            // Add all the curves in between
            for i in start.index+1 ..< end.index {
                //                print("ADDING: \(self.curves[i].description)")
                beziers.append(self.curves[i])
            }
            
            beziers.append(end.curve)
            //            print("ADDING: \(end.curve.description)")
        } else {
            let idx = start.index
            let length = self.length
            let currentCurve = self.curves[idx]
            let currentCurveLength = currentCurve.length
            var startPosition = length * startT
            var endPosition = length * endT
            
            for i in 0 ..< idx {
                let len = self.curves[i].length
                startPosition -= len
                endPosition -= len
            }
            
            let ccStart = startPosition/currentCurveLength
            let ccEnd = endPosition/currentCurveLength
            let curveBetween = currentCurve.subcurveBetween(ccStart, ccEnd)
            //            print("ADDING BTWN: \(curveBetween.description)")
            beziers.append(curveBetween)
        }
        
        return PiecewiseBezier(beziers)
    }
    
    private func _piecewiseAt(t: Float, isStart: Bool) -> (curve: Bezier, index: Int) {
        let piecewiseStart = self.length * t
        
        var pStart = piecewiseStart
        let curvesCount = self.curves.count
        
        for i in 0 ..< curvesCount {
            let curve = self.curves[i]
            let curveLength = curve.length
            if curveLength < pStart {
                // Move up the curve
                pStart -= curveLength
            } else {
                // Found!
                let curveT = pStart / curveLength
                let subcurve = isStart ?
                    curve.rightSubcurveAt(curveT) :
                    curve.leftSubcurveAt(curveT)
                return (subcurve, i)
            }
        }
        
        return (self.curves[0], -1)
    }
    
    public var description: String {
        var desc = ""
        for i in 0..<curves.count {
            let c = curves[i]
            desc += "\n \(i)) \(type(of: c)) - \(c.description)) "
        }
        return desc
    }
}
