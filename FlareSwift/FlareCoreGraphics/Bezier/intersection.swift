//
//  intersection.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 3/7/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

/// Describes intersections between two Bézier curves.
class Intersection {
    /// Parameter value on the first curve of the intersection.
    let t1: Float
    
    /// Parameter value on the second curve of the intersection.
    let t2: Float
    
    /// Constructs an intersection result with parameter values [t1] and [t2].
    init(t1: Float, t2: Float) {
        self.t1 = t1
        self.t2 = t2
    }
    
    /// Returns the maximum difference between the parameter value properties of [this]
    /// and [other].
    func maxTValueDifference(other: Intersection) -> Float {
        let t1Difference = abs(t1 - other.t1)
        let t2Difference = abs(t2 - other.t2)
        return max(t1Difference, t2Difference)
    }
    
    /// True if the difference of parameter values between [this] and [other] is
    /// less than or equal to [tValueDifference].
    func isWithinTValueOf(other: Intersection, tValueDifference: Float) -> Bool {
        return (maxTValueDifference(other: other) <= tValueDifference)
    }
    
    public var description: String { return "BDIntersection(\(t1), \(t2))" }
}
