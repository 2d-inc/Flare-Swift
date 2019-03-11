//
//  trim_path.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 3/8/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class PiecewiseBezier {
    private let curves: [Bezier]
    var transform = CGAffineTransform.identity
    
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
    
    func extractCGPath(_ start: Float, _ end: Float) -> CGPath? {
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
        
        let result = CGMutablePath()
        
        let btwn = self.between(startT: pStart, endT: pEnd)
        let beziers = btwn.curves
        
        if beziers.isEmpty {
            return result
        }
        
        let firstPoint = beziers.first!.points.first!
        result.move(to: CGPoint(x: firstPoint.x, y: firstPoint.y))
        
        for c in beziers {
            if c is Segment {
                let nextPoint = c.points[1]
                result.addLine(to: CGPoint(x: nextPoint.x, y: nextPoint.y))
            } else {
                let c1 = Vec2D.toCGPoint(c.points[1])
                let c2 = Vec2D.toCGPoint(c.points[2])
                let nextPoint = Vec2D.toCGPoint(c.points[3])
                result.addCurve(to: nextPoint, control1: c1, control2: c2)
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
            let length = self.length
            let currentCurve = self.curves[start.index]
            let currentCurveLength = currentCurve.length
            let startPosition = length * startT
            let endPosition = length * endT
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

func trimPath(_ paths : [PiecewiseBezier], _ startT: Float, _ stopT: Float, _ complement: Bool, _ isSequential: Bool) -> CGPath {
    if isSequential {
        return _trimPathSequential(paths, startT, stopT, complement)
    } else {
        return _trimPathSync(paths, startT, stopT, complement)
    }
}

private func _trimPathSync(_ paths: [PiecewiseBezier], _ startT: Float, _ stopT: Float, _ complement: Bool) -> CGPath {
    let result = CGMutablePath()
    
    for p in paths {
        let length = p.length
        let trimStart = length * startT
        let trimEnd = length * stopT
        
        if complement {
            if trimStart > 0 {
                _appendPathSegmentSync(p, result, 0.0, 0.0, trimStart)
            }
            if trimEnd < length {
                _appendPathSegmentSync(p, result, 0.0, trimEnd, length)
            }
        } else {
            if trimStart < trimEnd {
                _appendPathSegmentSync(p, result, 0.0, trimStart, trimEnd)
            }
        }
    }
    
    return result
}

private func _trimPathSequential(_ paths: [PiecewiseBezier], _ startT: Float, _ stopT: Float, _ complement: Bool) -> CGPath {
    let result = CGMutablePath()
    
    var totalLength: Float = 0
    for p in paths {
        totalLength += p.length
    }
    let trimStart = totalLength * startT
    let trimStop = totalLength * stopT
    var offset: Float = 0.0
    
    if complement {
        if trimStart > 0 {
            offset = _appendPathSegmentSequential(paths, result, offset, 0.0, trimStart)
        }
        if trimStop < totalLength {
            offset = _appendPathSegmentSequential(paths, result, offset, trimStart, trimStop)
        }
    } else {
        if trimStart < trimStop {
            offset = _appendPathSegmentSequential(paths, result, offset, trimStart, trimStop)
        }
    }
    
    return result
}

private func _appendPathSegmentSync(_ path: PiecewiseBezier, _ to: CGMutablePath, _ offset: Float, _ start: Float, _ stop: Float) {
    let nextOffset = offset + path.length
    if start < nextOffset {
        if let extracted = path.extractCGPath(start-offset, stop-offset) {
            to.addPath(extracted, transform: path.transform)
        }
    }
}

/// offset, start and stop are all relative to the length of the full path.
private func _appendPathSegmentSequential(_ paths: [PiecewiseBezier], _ to: CGMutablePath, _ offset: Float, _ start: Float, _ stop: Float) -> Float {
    var result = offset
    var nextOffset = offset
    
    for p in paths {
        nextOffset = offset + p.length
        if start < nextOffset {
            if let extracted = p.extractCGPath(start-offset, stop-offset) {
                to.addPath(extracted, transform: p.transform)
            }
            if stop < nextOffset {
                break
            }
        }
        result = nextOffset
    }
    
    return result
}
