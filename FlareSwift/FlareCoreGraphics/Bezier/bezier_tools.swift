//
//  bezier_tools.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 3/7/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

let legendrePolynomialRoots: [Float] = [
    -0.0514718425553177,
    0.0514718425553177,
    -0.1538699136085835,
    0.1538699136085835,
    -0.2546369261678899,
    0.2546369261678899,
    -0.3527047255308781,
    0.3527047255308781,
    -0.4470337695380892,
    0.4470337695380892,
    -0.5366241481420199,
    0.5366241481420199,
    -0.6205261829892429,
    0.6205261829892429,
    -0.6978504947933158,
    0.6978504947933158,
    -0.7677774321048262,
    0.7677774321048262,
    -0.8295657623827684,
    0.8295657623827684,
    -0.8825605357920527,
    0.8825605357920527,
    -0.9262000474292743,
    0.9262000474292743,
    -0.9600218649683075,
    0.9600218649683075,
    -0.9836681232797472,
    0.9836681232797472,
    -0.9968934840746495,
    0.9968934840746495
]

let legendrePolynomialWeights: [Float] = [
    0.1028526528935588,
    0.1028526528935588,
    0.1017623897484055,
    0.1017623897484055,
    0.0995934205867953,
    0.0995934205867953,
    0.0963687371746443,
    0.0963687371746443,
    0.0921225222377861,
    0.0921225222377861,
    0.0868997872010830,
    0.0868997872010830,
    0.0807558952294202,
    0.0807558952294202,
    0.0737559747377052,
    0.0737559747377052,
    0.0659742298821805,
    0.0659742298821805,
    0.0574931562176191,
    0.0574931562176191,
    0.0484026728305941,
    0.0484026728305941,
    0.0387991925696271,
    0.0387991925696271,
    0.0287847078833234,
    0.0287847078833234,
    0.0184664683110910,
    0.0184664683110910,
    0.0079681924961666,
    0.0079681924961666
]


/// True if [a] and [b] are within [precision] units of each other.
func isApproximately(_ a: Float, _ b: Float, precision: Float = 0.000001) -> Bool {
    return abs(a - b) <= precision
}

/// Returns the cube root of [realNumber] from within the real numbers such that
/// the result raised to the third power equals [realNumber].
func principalCubeRoot(_ realNumber: Float) -> Float {
    if (realNumber < 0.0) {
        return -pow(-realNumber, 1.0 / 3.0);
    } else {
        return pow(realNumber, 1.0 / 3.0);
    }
}

/// Returns a [List] of [Vector2] describing the derivative function of the
/// polynomial function described by [points].
func computeDerivativePoints(_ points: [Vec2D]) -> [Vec2D] {
    let derivativePointsCount = points.count - 1
    let multiplier = Float(derivativePointsCount)

    var derivativePoints = [Vec2D]()
    
    for index in 0 ..< derivativePointsCount {
        let point = Vec2D()
        Vec2D.copy(point, points[index+1])
        _ = Vec2D.subtract(point, point, points[index])
        _ = Vec2D.scale(point, point, multiplier)
        derivativePoints.insert(point, at: index)
    }
    
    return derivativePoints
}

/// Returns the signed angle in radians between the lines formed by [cornerPoint]
/// to [firstEndpoint] and [cornerPoint] to [secondEndpoint].
func cornerAngle(_ cornerPoint: Vec2D, _ firstEndpoint: Vec2D, _ secondEndpoint: Vec2D) -> Float {
    let deltaVector1 = Vec2D.init(clone: firstEndpoint)
    _ = Vec2D.subtract(deltaVector1, deltaVector1, cornerPoint)
    let deltaVector2 = Vec2D.init(clone: secondEndpoint)
    _ = Vec2D.subtract(deltaVector2, deltaVector2, cornerPoint)
    
    return Vec2D.angleToSigned(deltaVector1, deltaVector2)
}

/// Returns a [List] of [Vector2] positions from [points] translated so that
/// [lineStartPoint] is at the origin and rotated so that [lineEndPoint] is on
/// the positive X axis.
func alignWithLineSegment(_ points: [Vec2D], _ lineStartPoint: Vec2D, _ lineEndPoint: Vec2D) -> [Vec2D] {
//    final lineDeltaVector = new Vector2.copy(lineEndPoint);
//    lineDeltaVector.sub(lineStartPoint);
//
//    final xAxis = new Vector2(1.0, 0.0);
//
//    final lineAngle = -xAxis.angleToSigned(lineDeltaVector);
//    final rotationMatrix = new Matrix2.rotation(lineAngle);
//
//    final alignedPoints = <Vector2>[];
//    for (final point in points) {
//        final alignedPoint = new Vector2.copy(point);
//        alignedPoint.sub(lineStartPoint);
//        rotationMatrix.transform(alignedPoint);
//        alignedPoints.add(alignedPoint);
//    }
//    return alignedPoints;
    let lineDeltaVector = Vec2D.init(clone: lineEndPoint)
    _ = Vec2D.subtract(lineDeltaVector, lineDeltaVector, lineStartPoint)
    
    let xAxis = Vec2D(fromValues: 1.0, 0.0)
    
    let lineAngle = -(Vec2D.angleToSigned(xAxis, lineDeltaVector))
    let rotationMatrix = Mat2D()
    Mat2D.fromRotation(rotationMatrix, lineAngle)
    
    var alignedPoints = [Vec2D]()
    for point in points {
        let alignedPoint = Vec2D.init(clone: point)
        _ = Vec2D.subtract(alignedPoint, alignedPoint, lineStartPoint)
        _ = Vec2D.transformMat2D(alignedPoint, alignedPoint, rotationMatrix)
        alignedPoints.append(alignedPoint)
    }
    
    return alignedPoints
}

/// Returns the linear parameter value for where [t] lies in the interval
/// between [min] and [max].
///
/// If [t] is equal to [min], and [max] is greater than [min], it returns zero.
/// If [t] is equal to [max], and [max] is greater than [min], it returns one.
/// If [t] is between [min] and [max], it returns a value between zero and one.
///
/// ```
/// inverseMix(1.0, 2.0, 1.0) == 0.0;
/// inverseMix(1.0, 2.0, 2.0) == 1.0;
/// inverseMix(1.0, 2.0, 1.25) == 0.25;
/// ```
func inverseMix(_ min: Float, _ max: Float, _ t: Float) -> Float {
    return (t - min) / (max - min)
}

/// Returns roots for the cubic function that passes through [pa] at x == 0.0 and
/// [pd] at x == 1.0 which has control points [pb] and [pc] at x == 1.0 / 3.0 and
/// x == 2.0 / 3.0.
func cubicRoots(_ pa: Float, _ pb: Float, _ pc: Float, _ pd: Float) -> [Float] {
    let d = -pa + 3.0 * pb - 3.0 * pc + pd
    var a = 3.0 * pa - 6.0 * pb + 3.0 * pc
    var b = -3.0 * pa + 3.0 * pb
    var c = pa
    
    if (isApproximately(d, 0.0)) {
        if (isApproximately(a, 0.0)) {
            if (isApproximately(b, 0.0)) {
                // no solutions:
                return [];
            }
            // linear solution:
            return [-c / b]
        }
        // quadratic solutions:
        let q = sqrt(b * b - 4.0 * a * c)
        let a2 = 2.0 * a
        return [(q - b) / a2, (-b - q) / a2]
    }
    
    // cubic solutions:
    
    a /= d
    b /= d
    c /= d
    
    let p = (3.0 * b - a * a) / 3.0
    let thirdOfP = p / 3.0
    let q = (2.0 * a * a * a - 9.0 * a * b + 27.0 * c) / 27.0
    let halfOfQ = q / 2.0
    let discriminant = halfOfQ * halfOfQ + thirdOfP * thirdOfP * thirdOfP
    if (discriminant < 0.0) {
        let minusThirdOfPCubed = -(thirdOfP * thirdOfP * thirdOfP)
        let r = sqrt(minusThirdOfPCubed)
        let t = -q / (2.0 * r)
        let cosineOfPhi = min(max(t, -1.0), 1.0) // Clamp
        let phi = acos(cosineOfPhi)
        let cubeRootOfR = principalCubeRoot(r)
        let t1 = 2.0 * cubeRootOfR
        let x1 = t1 * cos(phi / 3.0) - a / 3.0
        let x2 = t1 * cos((phi + Float.pi * 2.0) / 3.0) - a / 3.0
        let x3 = t1 * cos((phi + Float.pi * 4.0) / 3.0) - a / 3.0
        return [x1, x2, x3]
    } else if (discriminant == 0.0) {
        let u1 = -principalCubeRoot(halfOfQ)
        let x1 = 2.0 * u1 - a / 3.0
        let x2 = -u1 - a / 3.0
        return [x1, x2]
    } else {
        let sd = sqrt(discriminant)
        let u1 = principalCubeRoot(-halfOfQ + sd)
        let v1 = principalCubeRoot(halfOfQ + sd)
        return [u1 - v1 - a / 3.0]
    }
}

/// Returns the roots for the quadratic function that passes through [a] at x == 0.0,
/// [c] at x == 1.0 and has a control point [b] at x == 0.5.
func quadraticRoots(_ a: Float, _ b: Float, _ c: Float) -> [Float] {
    let d = a - 2.0 * b + c;
    if (d != 0.0) {
        let m1 = -sqrt(b * b - a * c);
        let m2 = -a + b;
        let v1 = -(m1 + m2) / d;
        let v2 = -(-m1 + m2) / d;
        return [v1, v2];
    } else if ((b != c) && (d == 0.0)) {
        return [(2.0 * b - c) / (2.0 * (b - c))];
    } else {
        return [];
    }
}

/// Returns the root for the line passing through [a] at x == 0.0 and [b] at x == 1.0.
func linearRoots(_ a: Float, _ b: Float) -> [Float] {
    if (a == b) {
        return [Float]();
    } else {
        return [a / (a - b)];
    }
}

/// Returns an unfiltered [List] of roots for the polynomial function described
/// by [polynomial].
func polynomialRoots(_ polynomial: [Float]) -> [Float] {
    if (polynomial.count == 4) {
        return cubicRoots(
            polynomial[0], polynomial[1], polynomial[2], polynomial[3]);
    } else if (polynomial.count == 3) {
        return quadraticRoots(polynomial[0], polynomial[1], polynomial[2]);
    } else if (polynomial.count == 2) {
        return linearRoots(polynomial[0], polynomial[1]);
    } else if (polynomial.count < 2) {
        return [];
    } else {
        fatalError("Fourth and higher order polynomials not supported.")
    }
}

/// Returns the roots of the polynomial equation derived after aligning [points] along
/// the line passing through [lineStart] and [lineEnd].
func rootsAlongLine(_ points: [Vec2D], _ lineStart: Vec2D, _ lineEnd: Vec2D) -> [Float] {
    let alignedPoints = alignWithLineSegment(points, lineStart, lineEnd);
    
    var yValues = [Float]()
    for point in alignedPoints {
        yValues.append(point[1]);
    }
    
    var roots = polynomialRoots(yValues);
    
//    roots.retainWhere((t) => ((t >= 0.0) && (t <= 1.0)));
    roots.removeAll(where: { $0 < 0.0 && $0 > 1.0 })
    
    return roots;
}

/// Returns the intersection point between two lines.
///
/// The first line passes through [p1] and [p2].  The second line passes through
/// [p3] and [p4].  Returns [null] if the lines are parallel or coincident.
func intersectionPointBetweenTwoLines(_ p1: Vec2D, _ p2: Vec2D, _ p3: Vec2D, _ p4: Vec2D) -> Vec2D? {
    let cross1 = (p1[0] * p2[1] - p1[1] * p2[0]);
    let cross2 = (p3[0] * p4[1] - p3[1] * p4[0]);
    
    let xNumerator = cross1 * (p3[0] - p4[0]) - (p1[0] - p2[0]) * cross2;
    let yNumerator = cross1 * (p3[1] - p4[1]) - (p1[1] - p2[1]) * cross2;
    let denominator =
        (p1[0] - p2[0]) * (p3[1] - p4[1]) - (p1[1] - p2[1]) * (p3[0] - p4[0]);
    if (denominator == 0.0) {
        return nil
    }
    return Vec2D.init(fromValues: xNumerator/denominator, yNumerator/denominator)
}

/// Returns true if the dimensions of [box] when added together are smaller than
/// [maxSize].
func boundingBoxIsSmallerThanSize(_ box: AABB, _ maxSize: Float) -> Bool {
    let boxSize = AABB.size(Vec2D(), box)
    return boxSize[0] + boxSize[1] < maxSize
}

/// Returns the indices of pairs of curve segments that overlap from [pairLeftSides]
/// and [pairRightSides].
func indicesOfOverlappingSegmentPairs(_ pairLeftSides: [BezierSlice], _ pairRightSides: [BezierSlice]) -> [Int] {
    var overlappingIndices = [Int]()
//    for (var pairIndex = 0; pairIndex < pairLeftSides.length; pairIndex++) {
    for pairIndex in 0 ..< pairLeftSides.count {
        let leftSegment = pairLeftSides[pairIndex].subcurve;
        let rightSegment = pairRightSides[pairIndex].subcurve;
        if (leftSegment.overlaps(rightSegment)) {
            overlappingIndices.append(pairIndex);
        }
    }
    
    return overlappingIndices;
}

/// Returns a [List] of intersections between [curve1] and [curve2] using a
/// threshold of [curveIntersectionThreshold].  It divides the bounding boxes
/// of the [Bezier] curves in half and calls itself recursively with
/// overlapping pairs of divided curve segments.
func locateIntersectionsRecursively(_ curve1: BezierSlice, _ curve2: BezierSlice, _ curveIntersectionThreshold: Float) -> [Intersection] {
    let curve1Box = curve1.subcurve.boundingBox;
    let curve2Box = curve2.subcurve.boundingBox;
    
    if (boundingBoxIsSmallerThanSize(curve1Box, curveIntersectionThreshold) &&
        boundingBoxIsSmallerThanSize(curve2Box, curveIntersectionThreshold)) {
        let firstIntersectionT = (curve1.t1 + curve1.t2) / 2.0;
        let secondIntersectionT = (curve2.t1 + curve2.t2) / 2.0;
        return [Intersection(t1: firstIntersectionT, t2: secondIntersectionT)];
    }
    
    let centerT: Float = 0.5
    let curve1CenterT = mix(curve1.t1, curve1.t2, centerT);
    let curve2CenterT = mix(curve2.t1, curve2.t2, centerT);
    
    let curve1LeftSegment = curve1.subcurve.leftSubcurveAt(centerT);
    let curve1Left = BezierSlice(curve1LeftSegment, curve1.t1, curve1CenterT);
    
    let curve1RightSegment = curve1.subcurve.rightSubcurveAt(centerT);
    let curve1Right = BezierSlice(curve1RightSegment, curve1CenterT, curve1.t2);
    
    let curve2LeftSegment = curve2.subcurve.leftSubcurveAt(centerT);
    let curve2Left = BezierSlice(curve2LeftSegment, curve2.t1, curve2CenterT);
    
    let curve2RightSegment = curve2.subcurve.rightSubcurveAt(centerT);
    let curve2Right = BezierSlice(curve2RightSegment, curve2CenterT, curve2.t2);
    
    let pairLeftSides = [curve1Left, curve1Left, curve1Right, curve1Right];
    let pairRightSides = [curve2Left, curve2Right, curve2Left, curve2Right];
    
    let overlappingPairIndices = indicesOfOverlappingSegmentPairs(pairLeftSides, pairRightSides);
    
    var results = [Intersection]()
    if (overlappingPairIndices.isEmpty) {
        return results;
    }
    
    overlappingPairIndices.forEach({
        let left = pairLeftSides[$0];
        let right = pairRightSides[$0];
        results += locateIntersectionsRecursively(left, right, curveIntersectionThreshold)
    });
    
    return results;
}

/// Returns the index of the point in [points] that is closest (in terms of
/// geometric distance) to [targetPoint].
func indexOfNearestPoint(_ points: [Vec2D], _ targetPoint: Vec2D ) -> Int {
    var minSquaredDistance = Float.greatestFiniteMagnitude
    var index = 0
    
    let pointsCount = points.count
    for pointIndex in 0 ..< pointsCount {
        let point = points[pointIndex]
        let squaredDistance = Vec2D.distanceSquared(targetPoint, point)
        if (squaredDistance < minSquaredDistance) {
            minSquaredDistance = squaredDistance
            index = pointIndex
        }
    }
    
    return index;
}

/// Interpolate between [min] and [max] with the amount of [a] using a linear
/// interpolation. The computation is equivalent to the GLSL function mix.
func mix(_ min: Float, _ max: Float, _ a: Float) -> Float { return min + a * (max - min) }
