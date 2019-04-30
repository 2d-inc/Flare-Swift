//
//  aabb.swift
//  Flare
//
//  Created by Umberto Sonnino on 2/13/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import Darwin

public class AABB: Equatable, Hashable {
    var _buffer : [Float32]
    
    var values : [Float32] {
        get {
            return _buffer
        }
        set {
            _buffer = newValue
        }
    }
    
    var width: Float32 {
        return _buffer[2] - _buffer[0]
    }
    
    var height: Float32 {
        return _buffer[3] - _buffer[1]
    }
    
    public init() {
        self._buffer = [0.0, 0.0, 0.0, 0.0]
    }
    
    public init(clone copy: AABB) {
        self._buffer = copy.values
    }
    
    public init(fromValues a: Float32, _ b: Float32, _ c: Float32, _ d: Float32) {
        _buffer = [a, b, c, d]
    }
    
    // Equatable Protocol
    public static func == (lhs: AABB, rhs: AABB) -> Bool {
        guard lhs._buffer.count != rhs._buffer.count else {
            return false
        }
        let lBuf = lhs.values
        let rBuf = rhs.values
        let len = lBuf.count
        for i in 0 ..< len {
            if lBuf[i] != rBuf[i] {
                return false
            }
        }
        return true
    }
    
    // Hashable Protocol
    public func hash(into hasher: inout Hasher) {
        for f in _buffer {
            hasher.combine(f)
        }
    }
    
    // Overload [] operator for this class
    public subscript(index: Int) -> Float32 {
        get {
            return _buffer[index]
        }
        set {
            _buffer[index] = newValue
        }
    }
    
    static func copy(_ out: AABB, _ a: AABB) -> AABB {
        out[0] = a[0]
        out[1] = a[1]
        out[2] = a[2]
        out[3] = a[3]
        return out
    }
    
    static func center(_ out: Vec2D, _ a: AABB) -> Vec2D {
        out[0] = (a[0] + a[2]) * 0.5
        out[1] = (a[1] + a[3]) * 0.5
        return out
    }
    
    static func size(_ out: Vec2D, _ a: AABB) -> Vec2D {
        out[0] = a[2] - a[0]
        out[1] = a[3] - a[1]
        return out
    }
    
    static func extents(_ out: Vec2D, _ a: AABB) -> Vec2D {
        out[0] = (a[2] - a[0]) * 0.5
        out[1] = (a[3] - a[1]) * 0.5
        return out
    }
    
    static func perimeter(_ a: AABB) -> Float32 {
        let wx = a[2] - a[0]
        let wy = a[3] - a[1]
        return 2.0 * (wx + wy)
    }
    
    static func combine(_ out: AABB, _ a: AABB, _ b: AABB) -> AABB {
        out[0] = min(a[0], b[0])
        out[1] = min(a[1], b[1])
        out[2] = max(a[2], b[2])
        out[3] = max(a[3], b[3])
        return out
    }
    
    static func contains(_ a: AABB, _ b: AABB) -> Bool {
        return a[0] <= b[0] && a[1] <= b[1] && b[2] <= a[2] && b[3] <= a[3]
    }
    
    static func isValid(_ a: AABB) -> Bool {
        let dx = a[2] - a[0]
        let dy = a[3] - a[1]
        return
            dx >= 0 &&
            dy >= 0 &&
            a[0] <= .greatestFiniteMagnitude &&
            a[1] <= .greatestFiniteMagnitude &&
            a[2] <= .greatestFiniteMagnitude &&
            a[3] <= .greatestFiniteMagnitude
    }
    
    static func testOverlap(_ a: AABB, _ b: AABB) -> Bool {
        let d1x = b[0] - a[2]
        let d1y = b[1] - a[3]
        
        let d2x = a[0] - b[2]
        let d2y = a[1] - b[3]
        
        if (d1x > 0.0 || d1y > 0.0) {
            return false
        }
        
        if (d2x > 0.0 || d2y > 0.0) {
            return false
        }
        
        return true
    }
    
    static func intersectsWithVec2D(_ aabb: AABB, _ vec: Vec2D) -> Bool {
        return aabb[0] <= vec[0] &&
                aabb[1] <= vec[1] &&
                aabb[2] >= vec[0] &&
                aabb[3] >= vec[1]
    }
}
