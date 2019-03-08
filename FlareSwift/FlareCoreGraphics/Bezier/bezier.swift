//
//  bezier.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 3/7/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//
// Credits to

import Foundation


 class BezierFactory {
     let linearTolerance: Float = 0.0001
     let originIntersectionTestDistance: Float = 10.0
    
     static func fromPoints(_ curvePoints: [Vec2D]) -> Bezier {
             if curvePoints.count == 3 {
                 return QuadraticBezier(curvePoints)
             } else if curvePoints.count == 4 {
                return CubicBezier(curvePoints)
             } else {
                fatalError("Unsupported number of curve points!")
        }
     }
    
 }

protocol Bezier: class {
    var linearTolerance: Float { get }
    var originIntersectionTestDistance: Float { get }
    var points: [Vec2D] { get set }
    var order: Int { get }
    
    var startPoint: Vec2D { get }
    var endPoint: Vec2D { get }
    var firstOrderDerivativePoints: [Vec2D] { get }
    var isClockwise: Bool { get }
    var isLinear: Bool { get }
    var length: Float { get }
    var boundingBox: AABB { get }
    
    func pointAt(_ t: Float) -> Vec2D
    func derivativePoints(_ derivativeOrder: Int) -> [Vec2D]
    func derivativeAt(_ t: Float, _ cachedFirstOrderDerivativePoints: [Vec2D]?) -> Vec2D
    func _interpolatedPoints(_ pointsToInterpolate: [Vec2D], _ t: Float) -> [Vec2D]
    func _interpolateRecursively(_ pointsToInterpolate: [Vec2D], _ t: Float) -> [Vec2D]
    func hullPointsAt(_ t: Float) -> [Vec2D]
    func normalAt(_ t: Float, _ cachedFirstOrderDerivativePoints: [Vec2D]?) -> Vec2D
    func overlaps(_ curve: Bezier) -> Bool
    func leftSubcurveAt(_ t: Float) -> Bezier
    func rightSubcurveAt(_ t: Float) -> Bezier
    func subcurveBetween(_ t1: Float, _ t2: Float) -> Bezier
}

extension Bezier {
    var originIntersectionTestDistance: Float {
        return 10.0
    }
    
    var linearTolerance: Float {
        return 0.0001
    }
    
    var startPoint: Vec2D {
        return points[0]
    }
    
    var endPoint: Vec2D {
        let last = points.endIndex-1
        return points[last]
    }
    
    var firstOrderDerivativePoints: [Vec2D] {
        return computeDerivativePoints(points)
    }
    
    var isClockwise: Bool {
        let firstControlPoint = points[1]
        let angle = cornerAngle(startPoint, endPoint, firstControlPoint)
        return angle > 0.0
    }
    
    var isLinear: Bool {
        let alignedPoints = alignWithLineSegment(points, startPoint, endPoint)
        for alignedPoint in alignedPoints {
            if abs(alignedPoint[1]) > linearTolerance {
                return false
            }
        }
        return true
    }
    
    var length: Float {
        let z: Float = 0.5
        let tValuesCount = legendrePolynomialRoots.count
        var sum: Float = 0.0
        let cachedPoints = firstOrderDerivativePoints
        for index in 0 ..< tValuesCount {
            let t = z * legendrePolynomialRoots[index] + z
            let d = derivativeAt(t, cachedPoints)
            sum += legendrePolynomialWeights[index] * Vec2D.length(d)
        }
        return z * sum
    }
    
    var boundingBox: AABB {
        var extremaTValues = self.extrema
        if !extremaTValues.contains(0.0) {
            extremaTValues.insert(0.0, at: 0)
        }
        
        if !extremaTValues.contains(1.0) {
            extremaTValues.append(1.0)
        }
        
        let minPoint = Vec2D.init(fromValues: Float.infinity, Float.infinity)
        let maxPoint = Vec2D.init(fromValues: -Float.infinity, -Float.infinity)
        
        for v in extremaTValues {
            let point = pointAt(v)
            Vec2D.min(minPoint, point, minPoint)
            Vec2D.max(maxPoint, point, maxPoint)
        }
        
        return AABB.init(fromValues: minPoint[0], minPoint[1], maxPoint[0], maxPoint[1])
        
    }
    
    /// Returns the parameter values that correspond with minimum and maximum values
    /// on the x axis.
    //    List<double> get extremaOnX => _extremaOnAxis((v) => v.x);
    var extremaOnX: [Float] {
        return _extremaOnAxis({ (v: Vec2D) -> Float in return v[0] })
    }
    
    /// Returns the parameter values that correspond with minimum and maximum values
    /// on the y axis.
    //    List<double> get extremaOnY => _extremaOnAxis((v) => v.y);
    var extremaOnY: [Float] {
        return _extremaOnAxis({ (v: Vec2D) -> Float in return v[1] })
    }
    
    /// Returns the parameter values that correspond with extrema on both the x
    /// and y axes.
    var extrema: [Float] {
        var roots = [Float]()
        roots.append(contentsOf: extremaOnX)
        roots.append(contentsOf: extremaOnY)
        
        let rootSet = Set(roots)
        var uniqueRoots = Array(rootSet)
        uniqueRoots.sort()
        
        return uniqueRoots
    }
    
    
    func derivativePoints(_ derivativeOrder: Int = 1) -> [Vec2D] {
        if derivativeOrder == 1 {
            return firstOrderDerivativePoints
        } else if derivativeOrder > self.order {
            return []
        } else if derivativeOrder < 1 {
            fatalError("Invalid order for derivatives! \(derivativeOrder)")
        }
        
        let pointsToProcess = derivativePoints(derivativeOrder-1)
        return computeDerivativePoints(pointsToProcess)
    }
    
    func _interpolatedPoints(_ pointsToInterpolate: [Vec2D], _ t: Float) -> [Vec2D] {
        var interpolatedPoints = [Vec2D]()
        
        for index in 0 ..< pointsToInterpolate.count-1 {
            let point = Vec2D()
            Vec2D.mix(point, pointsToInterpolate[index], pointsToInterpolate[index+1], t)
            interpolatedPoints.append(point)
        }
        
        return interpolatedPoints
    }
    
    func _interpolateRecursively(_ pointsToInterpolate: [Vec2D], _ t: Float) -> [Vec2D] {
        if pointsToInterpolate.count > 1 {
            var result = pointsToInterpolate
            let interpolatedPoints = _interpolatedPoints(pointsToInterpolate, t)
            result.append(contentsOf: _interpolateRecursively(interpolatedPoints, t))
            return result
        } else {
            return pointsToInterpolate
        }
    }
    
    func hullPointsAt(_ t: Float) -> [Vec2D] {
        var hullPoints = [Vec2D]()
        for index in 0 ... order {
            let hullPoint = Vec2D()
            Vec2D.copy(hullPoint, points[index])
            hullPoints.append(hullPoint)
        }
        
        return _interpolateRecursively(hullPoints, t)
    }
    
    func normalAt(_ t: Float, _ cachedFirstOrderDerivativePoints: [Vec2D]?) -> Vec2D {
        let d = derivativeAt(t, cachedFirstOrderDerivativePoints)
        Vec2D.normalize(d, d)
        return Vec2D(fromValues: -d[1], d[0])
    }
    
    func overlaps(_ curve: Bezier) -> Bool {
        let thisBox = self.boundingBox
        let otherBox = curve.boundingBox
        
        return AABB.testOverlap(thisBox, otherBox)
    }
    
    func leftSubcurveAt(_ t: Float) -> Bezier {
        if t <= 0.0 {
            fatalError("Cannot split a curve left of a start point!")
        }
        
        let tt = min(t, 1.0)
        
        let hullPoints = hullPointsAt(tt)
        switch order {
        case 2:
            return QuadraticBezier([hullPoints[0], hullPoints[3], hullPoints[5]])
        case 3:
            return CubicBezier([hullPoints[0], hullPoints[4], hullPoints[7], hullPoints[9]])
        default:
            fatalError("Unsupported Curve Order!")
        }
    }
    
    func rightSubcurveAt(_ t: Float) -> Bezier {
        if t >= 1.0 {
            fatalError("Cannot split a curve left of a start point!")
        }
        
        let tt = max(t, 0.0)
        
        let hullPoints = hullPointsAt(tt)
        switch order {
        case 2:
            return QuadraticBezier([hullPoints[5], hullPoints[4], hullPoints[2]])
        case 3:
            return CubicBezier([hullPoints[9], hullPoints[8], hullPoints[6], hullPoints[3]])
        default:
            fatalError("Unsupported Curve Order!")
        }
    }
    
    func subcurveBetween(_ t1: Float, _ t2: Float) -> Bezier {
        let rightOfT1 = rightSubcurveAt(t1)
        let adjustedT2 = inverseMix(t1, 1.0, t2)
        
        return rightOfT1.leftSubcurveAt(adjustedT2)
    }
    
    func _extremaOnAxis(_ mappingFunction: ((Vec2D) -> Float) ) -> [Float] {
        let firstOrderPoints = derivativePoints(1);
        let firstOrderPolynomial = firstOrderPoints.map(mappingFunction)
        
        var result = [Float]()
        result.append(contentsOf: polynomialRoots(firstOrderPolynomial))
        
        if (order == 3) {
            let secondOrderPoints = derivativePoints(2);
            let secondOrderPolynomial = secondOrderPoints.map(mappingFunction)
            result.append(contentsOf: polynomialRoots(secondOrderPolynomial))
        }
        
        result.removeAll(where: { $0 < 0.0 && $0 > 1.0 })
        result.sort();
        return result;
    }
    
    /// The normal vector at [t] taking into account overlapping control
    /// points at the end point with index [endPointIndex] in [points].
    func _nonOverlappingNormalVectorAt(_ t: Float, _ endPointIndex: Int, _ cachedPoints: [Vec2D]) -> Vec2D {
        let normalVector = normalAt(t, cachedPoints);
        if ((normalVector[0] != 0.0) || (normalVector[1] != 0.0)) {
            return normalVector;
        }
        
        let iterationsCount = order - 1

        for iteration in 0 ..< iterationsCount {
            var pointIndex = iteration + 2;
            var tangentScaleFactor: Float = 1.0;
            if (endPointIndex > 0) {
                pointIndex = (endPointIndex - 2) - iteration;
                tangentScaleFactor = -1.0;
            }
        
            let tangentVector = Vec2D.init(clone: points[pointIndex])
            _ = Vec2D.subtract(tangentVector, tangentVector, points[endPointIndex])
            _ = Vec2D.scale(tangentVector, tangentVector, tangentScaleFactor)
            let tangentMagnitude = Vec2D.length(tangentVector)
            if (tangentMagnitude != 0.0) {
                return Vec2D.init(fromValues: -tangentVector[1], tangentVector[0])
            }
        }
        return Vec2D()
    }
    
    /// True if the normal vectors at the start and end points form an angle less
    /// than 60 degrees.
    ///
    /// Cubic curves have the additional restriction of needing
    /// both control points on the same side of the line between the guide points.
    var isSimple: Bool {
        if (order == 3) {
            let startAngle = cornerAngle(startPoint, endPoint, points[1]);
            let endAngle = cornerAngle(startPoint, endPoint, points[2]);
            if (((startAngle > 0.0) && (endAngle < 0.0)) || ((startAngle < 0.0) && (endAngle > 0.0))) {
                return false;
            }
        }
        
        let firstOrderPoints = firstOrderDerivativePoints;
        let startPointNormal = _nonOverlappingNormalVectorAt(0.0, 0, firstOrderPoints);
        let endPointNormal = _nonOverlappingNormalVectorAt(1.0, order, firstOrderPoints);
        
        let normalDotProduct = Vec2D.dot(startPointNormal, endPointNormal)
        let clampedDotProduct = min(max(normalDotProduct, -1.0), 1.0)
        let angle = abs(acos(clampedDotProduct));
        
        return (angle < Float.pi / 3.0);
    }
    
    /// Returns a [List] of subcurve segments of [this] between the parameter
    /// values for extrema.
    func _slicesBetweenExtremaTValues() -> [BezierSlice] {
        var curvePortionsBetweenExtrema = [BezierSlice]()
        
        var extremaTValues = extrema
        if (!(extremaTValues.contains(0.0))) {
//            extremaTValues.insert(0, 0.0);
            extremaTValues.insert(0.0, at: 0)
        }
        if (!(extremaTValues.contains(1.0))) {
            extremaTValues.append(1.0);
        }
        
        var t1 = extremaTValues[0];

        for extremityIndex in 1 ..< extremaTValues.count {
                let t2 = extremaTValues[extremityIndex];
                let subcurve = subcurveBetween(t1, t2);
                let reductionResult = BezierSlice(subcurve, t1, t2);
                curvePortionsBetweenExtrema.append(reductionResult);
                t1 = t2;
        }
        
        return curvePortionsBetweenExtrema;
    }
    
    /// Returns a [List] of simple subcurve segments from [slicesToProcess].
    ///
    /// It divides each curve in [slicesToProcess] from a starting parameter
    /// value to an ending parameter value in search of non-simple portions.  When
    /// a non-simple portion is found, it backtracks and adds the last known simple
    /// portion to the returned value.
    func _divideNonSimpleSlices(_ slicesToProcess: [BezierSlice], _ stepSize: Float) -> [BezierSlice] {
        var simpleSlices = [BezierSlice]()
        
        for slice in slicesToProcess {
            if (slice.subcurve.isSimple) {
                simpleSlices.append(slice);
                continue;
            }
            
            var t1: Float = 0.0;
            var t2: Float = 0.0;
            var subcurve: Bezier!
            
            while (t2 <= 1.0) {
//                for (t2 = t1 + stepSize; t2 <= 1.0 + stepSize; t2 += stepSize) {
                t2 = t1+stepSize
                while t2 <= 1.0+stepSize {
//                for t2 in stride(from: t1+stepSize, to: 1.0+stepSize, by: stepSize) {
                    subcurve = slice.subcurve.subcurveBetween(t1, t2);
                    if (!(subcurve.isSimple)) {
                        t2 -= stepSize;
                        let reductionIsNotPossible = (abs(t1 - t2) < stepSize);
                        if (reductionIsNotPossible) {
                            return [];
                        }
                        subcurve = slice.subcurve.subcurveBetween(t1, t2);
                        let subcurveT1 = mix(slice.t1, slice.t2, t1);
                        let subcurveT2 = mix(slice.t1, slice.t2, t2);
                        let result = BezierSlice(subcurve, subcurveT1, subcurveT2);
                        simpleSlices.append(result);
                        t1 = t2;
                        break;
                    }
                    t2 += stepSize
                }
            }
            if (t1 < 1.0) {
                subcurve = slice.subcurve.subcurveBetween(t1, 1.0);
                let subcurveT1 = mix(slice.t1, slice.t2, t1);
                let subcurveT2 = slice.t2;
                let result = BezierSlice(subcurve, subcurveT1, subcurveT2);
                simpleSlices.append(result);
            }
        }
        
        return simpleSlices;
    }
    
    /// Returns a [List] of [BezierSlice] instances containing simple [Bezier]
    /// instances along with their endpoint parameter values from [this].  In
    /// cases where no simple subcurves can be found with the given [stepSize],
    /// returns an empty [List].
    ///
    /// Refer to [simpleSubcurves] for information about the optional parameter [stepSize].
    /// If endpoint parameter values of the component curves are not needed, use [simpleSubcurves]
    /// instead.
    func simpleSlices(stepSize: Float = 0.01) -> [BezierSlice] {
        let subcurvesBetweenExtrema = _slicesBetweenExtremaTValues();
        return _divideNonSimpleSlices(subcurvesBetweenExtrema, stepSize);
    }
    
    /// Returns a [List] of simple [Bezier] instances that make up [this] when
    /// taken together.  In cases where no simple subcurves can be found with the
    /// given [stepSize], returns an empty [List].
    ///
    /// Reduction is performed in two passes.  The first pass splits the curve at the
    /// parameter values of extrema along the x and y axes.  The second pass divides
    /// any non-simple portions of the curve into simple curves.  The optional [stepSize]
    /// parameter determines how much to increment the parameter value at each iteration
    /// when searching for non-simple portions of curves.  The default [stepSize]
    /// value of 0.01 means that the function will do around one hundred iterations
    /// for each segment between the parameter values for extrema.  Reducing the value
    /// of [stepSize] will increase the number of iterations.
    func simpleSubcurves(stepSize: Float = 0.01) -> [Bezier] {
        let reductionResults = simpleSlices(stepSize: stepSize);
        return reductionResults.map({ return $0.subcurve })
    }
    
    /// Returns the point [distance] units away in the clockwise direction from
    /// the point along the curve at parameter value [t].
    ///
    /// See [derivativeAt] for information about the optional parameter [cachedFirstOrderDerivativePoints].
    func offsetPointAt(_ t: Float, _ distance: Float, cachedFirstOrderDerivativePoints: [Vec2D]?) -> Vec2D {
        let offsetPoint = pointAt(t)
        let normalVector = normalAt(t, cachedFirstOrderDerivativePoints);
        
        _ = Vec2D.scaleAndAdd(offsetPoint, offsetPoint, normalVector, distance)
        
        return offsetPoint;
    }
    
    /// Returns a [List] of [Bezier] instances that, when taken together, form an approximation
    /// of the offset curve [distance] units away from [this].
    ///
    /// See [simpleSubcurves] for information about the optional parameter [stepSize].
    func offsetCurve(_ distance: Float, stepSize: Float = 0.01) -> [Bezier] {
        if (isLinear) {
            return [_translatedLinearCurve(distance)];
        }
        
        let reducedSegments = simpleSubcurves(stepSize: stepSize);
//        let offsetSegments = reducedSegments.map((s) => s.scaledCurve(distance));
        let offsetSegments = reducedSegments.map({ return $0.scaledCurve(distance) })
        return offsetSegments
    }
    
    /// Returns a [Bezier] instance with [points] translated by [distance] units
    /// along the normal vector at the start point.
    func _translatedLinearCurve(_ distance: Float) -> Bezier {
        let normalVector = _nonOverlappingNormalVectorAt(0.0, 0, firstOrderDerivativePoints);
        var translatedPoints = [Vec2D]()
        for point in points {
            let translatedPoint = Vec2D.init(clone: point)
            _ = Vec2D.scaleAndAdd(translatedPoint, translatedPoint, normalVector, distance)
            translatedPoints.append(translatedPoint);
        }
        return BezierFactory.fromPoints(translatedPoints);
    }
    
    /// Returns the origin used for calculating control point positions in scaled curves.
    ///
    /// Usually the intersection point between the endpoint normal vectors.  In the
    /// case of cubic curves with parallel or anti-parallel endpoint normal vectors,
    /// the origin is the midpoint between the start and end points.
    var _scalingOrigin: Vec2D {
        let firstOrderPoints = firstOrderDerivativePoints;
        let offsetStart = _nonOverlappingOffsetPointAt(0.0, originIntersectionTestDistance, 0, firstOrderPoints);
        let offsetEnd = _nonOverlappingOffsetPointAt(1.0, originIntersectionTestDistance, order, firstOrderPoints);
        let intersectionPoint = intersectionPointBetweenTwoLines(offsetStart, startPoint, offsetEnd, endPoint);
        if (intersectionPoint == nil) {
            let centerPoint = Vec2D()
//            Vector2.mix(startPoint, endPoint, 0.5, centerPoint);
            Vec2D.mix(startPoint, endPoint, centerPoint, 0.5)
            return centerPoint;
        } else {
            return intersectionPoint!
        }
    }
    
    /// Returns the point at [t] offset by [distance] along the normal vector calculated
    /// by [_nonOverlappingNormalVectorAt].
    func _nonOverlappingOffsetPointAt(_ t: Float, _ distance: Float, _ endPointIndex: Int, _ cachedPoints: [Vec2D]) -> Vec2D {
        let offsetPoint = pointAt(t);
        let normalVector = _nonOverlappingNormalVectorAt(t, endPointIndex, cachedPoints);
        _ = Vec2D.scaleAndAdd(offsetPoint, offsetPoint, normalVector, distance)
//        offsetPoint.addScaled(normalVector, distance);
        return offsetPoint;
    }
    
    /// Returns a [Bezier] instance whose endpoints are [distance] units away from the
    /// endpoints of [this] and whose control points have been moved in the same direction.
    ///
    /// Results are best on simple curves.  Although [scaledCurve] can be called on non-simple
    /// curves, the return value may not resemble a proper offset curve.  For better results
    /// on non-simple curves, try [offsetCurve].
    ///
    /// A scaled linear curve is translated by [distance] units along its start
    /// point normal vector.
    func scaledCurve(_ distance: Float) -> Bezier {
        if (isLinear) {
            return _translatedLinearCurve(distance);
        }
        
        let origin = _scalingOrigin;
        
        let listLength = order + 1;
        var scaledCurvePoints = [Vec2D?](repeating: nil, count: listLength)
        
        let firstOrderPoints = firstOrderDerivativePoints;
        
        let scaledStartPoint = _nonOverlappingOffsetPointAt(0.0, distance, 0, firstOrderPoints);
        scaledCurvePoints.insert(scaledStartPoint, at: 0)
        
        let scaledEndPoint = _nonOverlappingOffsetPointAt(1.0, distance, order, firstOrderPoints);
        scaledCurvePoints[order] = scaledEndPoint;
        
        let startTangentPoint = Vec2D.init(clone: scaledStartPoint)
        _ = Vec2D.add(startTangentPoint, startTangentPoint, derivativeAt(0.0, firstOrderPoints))
        
        if let intersectionPoint = intersectionPointBetweenTwoLines(scaledStartPoint, startTangentPoint, origin, points[1]) {
            scaledCurvePoints.insert(intersectionPoint, at: 1)
        } else {
            scaledCurvePoints.insert(startTangentPoint, at: 1)
        }
        
        if (order == 3) {
            let endTangentPoint = Vec2D.init(clone: scaledEndPoint)
            _ = Vec2D.add(endTangentPoint, endTangentPoint, derivativeAt(1.0, firstOrderPoints))
            if let intersectionPoint = intersectionPointBetweenTwoLines(scaledEndPoint, endTangentPoint, origin, points[2]) {
                scaledCurvePoints.insert(intersectionPoint, at: 2)
            } else {
                scaledCurvePoints.insert(endTangentPoint, at: 2)
            }
        }
        
        // TODO: check that his is correct, might be missing one point.
        return BezierFactory.fromPoints(scaledCurvePoints as! [Vec2D])
    }
    
    /// Returns a [List] of intersection results after removing duplicates in [intersectionsToFilter].
    static func _removeDuplicateIntersections(_ intersectionsToFilter: [Intersection], _ minTValueDifference: Float) -> [Intersection] {
        if (intersectionsToFilter.count <= 1) {
            return intersectionsToFilter;
        }
        
        var firstIntersection = intersectionsToFilter[0];
//        let sublist = intersectionsToFilter.sublist(1);
        var sublist = intersectionsToFilter.suffix(from: 1)
        var filteredList = [Intersection]()
        while !sublist.isEmpty {
//            sublist.removeWhere((intersection) {
//                return intersection.isWithinTValueOf(
//                    firstIntersection, minTValueDifference);
//            });
            sublist.removeAll(where: {
                return $0.isWithinTValueOf(other: firstIntersection, tValueDifference: minTValueDifference)
            })
            
            if !sublist.isEmpty {
                firstIntersection = sublist[0];
//                sublist = sublist.sublist(1);
                sublist = sublist.suffix(from: 1)
                filteredList.append(firstIntersection);
            }
        }
        return filteredList;
    }
    
    /// Returns a [List] of intersection results between [curve1] and [curve2].
    static func _locateIntersections(_ curve1: [BezierSlice], _ curve2: [BezierSlice], _ curveIntersectionThreshold: Float, _ minTValueDifference: Float) -> [Intersection] {
        var leftOverlappingSegments = [BezierSlice]()
        var rightOverlappingSegments = [BezierSlice]()
        curve1.forEach { (left : BezierSlice) in
            curve2.forEach({ (right: BezierSlice) in
                if left.subcurve.overlaps(right.subcurve) {
                    leftOverlappingSegments.append(left)
                    rightOverlappingSegments.append(right)
                }
            })
        }
        
        var intersections = [Intersection]()
        let overlappingSegmentsCount = leftOverlappingSegments.count
        for pairIndex in 0 ..< overlappingSegmentsCount {
            let leftCurve = leftOverlappingSegments[pairIndex];
            let rightCurve = rightOverlappingSegments[pairIndex];
            let result = locateIntersectionsRecursively(leftCurve, rightCurve, curveIntersectionThreshold);
            intersections.append(contentsOf: result)
        }
        
        return _removeDuplicateIntersections(intersections, minTValueDifference);
    }
    
    /// Returns the [List] of intersections between [this] and [curve].
    ///
    /// The optional parameter [curveIntersectionThreshold] determines how small
    /// to divide the bounding boxes of overlapping segments in the search for
    /// intersection points.  This value is in the coordinate space of the curve.
    /// The optional parameter [minTValueDifference] specifies how far away
    /// intersection results must be from each other in terms of curve parameter
    /// values to be considered separate intersections.
    ///
    /// With the optional parameters at their default values, this method may return
    /// more than the expected number of intersections for curves that cross at a
    /// shallow angle or pass extremely close to each other. Decreasing
    /// [curveIntersectionThreshold] or increasing [minTValueDifference] may
    /// reduce the number of intersections returned in such cases.
    func intersectionsWithCurve(_ curve: Bezier, _ curveIntersectionThreshold: Float = 0.5, _ minTValueDifference: Float = 0.003) -> [Intersection] {
        let reducedSegments = simpleSlices();
        let curveReducedSegments = curve.simpleSlices();
        
        return Self._locateIntersections(reducedSegments, curveReducedSegments, curveIntersectionThreshold, minTValueDifference);
    }
    
    /// Returns the [List] of intersections between [this] and itself.
    ///
    /// See [intersectionsWithCurve] for information about the optional parameters.
    func intersectionsWithSelf(_ curveIntersectionThreshold: Float = 0.5, _ minTValueDifference: Float = 0.003) -> [Intersection] {
        let reducedSegments = simpleSlices();
        var results = [Intersection]()
        
        for segmentIndex in 0 ..< reducedSegments.count-2 {
            let left = reducedSegments[segmentIndex...segmentIndex+1]
            let right = reducedSegments.suffix(from: segmentIndex+2)
            let result = Self._locateIntersections(Array(left), Array(right), curveIntersectionThreshold, minTValueDifference);
            results.append(contentsOf: result);
        }
        
        return results;
    }
    
    /// Returns the [List] of parameter values for intersections between [this] and
    /// the line segment defined by [lineStartPoint] and [lineEndPoint].
    func intersectionsWithLineSegment(_ lineStartPoint: Vec2D, _ lineEndPoint: Vec2D) -> [Float] {
        let minPoint = Vec2D()
//        Vector2.min(lineStartPoint, lineEndPoint, minPoint);
        Vec2D.min(minPoint, lineStartPoint, lineEndPoint)
        
        let maxPoint = Vec2D()
//        Vector2.max(lineStartPoint, lineEndPoint, maxPoint);
        Vec2D.max(maxPoint, lineStartPoint, lineEndPoint)
        
//        let boundingBox = new Aabb2.minMax(minPoint, maxPoint);
        let boundingBox = AABB.init(fromValues: minPoint[0], minPoint[1], maxPoint[0], maxPoint[1])
        
        var roots = rootsAlongLine(points, lineStartPoint, lineEndPoint);
//        roots.retainWhere((t) {
//            let p = pointAt(t);
//            return boundingBox.intersectsWithVector2(p);
//        });
        roots.removeAll { (t: Float) -> Bool in
            let p = pointAt(t)
            return !AABB.intersectsWithVec2D(boundingBox, p)
        }
        let rootsSet = Set(roots)
        let uniqueRoots = Array(rootsSet)
        return uniqueRoots;
    }
    
    /// Returns a [List] of [Vector2] positions at evenly spaced parameter values from 0.0 to 1.0.
    ///
    /// The [intervalsCount] parameter is used to calculate the size of the interval.
    /// The returned List will contain [intervalsCount] + 1 entries.
    ///
    /// Note that although the returned positions will be parametrically equidistant,
    /// the arc length between them may vary significantly.  To obtain more evenly
    /// distributed positions along the arc, use the [EvenSpacer] class.
    func positionLookUpTable(_ intervalsCount: Int = 50) -> [Vec2D] {
        var lookUpTable = [Vec2D]()
        
        for index in 0 ... intervalsCount {
            let parameterValue = Float(index) / Float(intervalsCount)
            let position = pointAt(parameterValue);
            lookUpTable.append(position);
        }
        
        return lookUpTable;
    }
    
    /// Returns the parameter value along the curve that is closest (in terms of
    /// geometric distance) to the given [point].  The approximation uses a
    /// two-pass projection test that relies on the curve's position look up
    /// table.  First, the method determines the point in the look up table that
    /// is closest to [point].  Afterward, it checks the fine interval around that
    /// point to see if a better projection can be found.
    ///
    /// The optional parameter [cachedPositionLookUpTable] allows the method to
    /// use previously calculated values for [positionLookUpTable] instead
    /// of repeating the calculations.  The optional [stepSize] parameter
    /// determines how much to increment the parameter value at each iteration
    /// when searching the fine interval for the best projection.  The default
    /// [stepSize] value of 0.1 means that the function will do around twenty
    /// iterations.  Reducing the value of [stepSize] will increase the number of
    /// iterations.
    func nearestTValue(_ point: Vec2D, _ cachedPositionLookUpTable: [Vec2D]?, _ stepSize: Float = 0.1) -> Float {
        let lookUpTable = cachedPositionLookUpTable ?? positionLookUpTable();
        
        let index = indexOfNearestPoint(lookUpTable, point);
        
        let maxIndex = lookUpTable.count - 1;
        
        if (index == 0) {
            return 0.0;
        } else if (index == maxIndex) {
            return 1.0;
        }
        
        let intervalsCount = Float(maxIndex)
        let t1 = Float(index - 1) / intervalsCount;
        let t2 = Float(index + 1) / intervalsCount;
        
        let tIncrement = stepSize / intervalsCount;
        let maxT = t2 + tIncrement;
        
        var t = t1;
        var minSquaredDistance = Float.greatestFiniteMagnitude
        var nearestT = t1;
        
        while (t < maxT) {
            let pointOnCurve = pointAt(t);
            let squaredDistance = Vec2D.distanceSquared(point, pointOnCurve)
            
            if (squaredDistance < minSquaredDistance) {
                minSquaredDistance = squaredDistance;
                nearestT = t;
            }
            t += tIncrement;
        }
        
        return nearestT;
    }
    
}
