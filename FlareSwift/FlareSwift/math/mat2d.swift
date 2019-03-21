//
//  mat2d.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/12/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public class Mat2D: Equatable, Hashable {
    var _buffer : [Float32]
    
    var values : [Float32] {
        get {
            return self._buffer
        }
        set {
            self._buffer = newValue
        }
    }
    
    // Overload [] operator for this class
    subscript(index: Int) -> Float32 {
        get {
            return _buffer[index]
        }
        set {
            _buffer[index] = newValue
        }
    }
    
    var mat4 : [Float32] {
        get {
            return [
                _buffer[0],
                _buffer[1],
                0.0,
                0.0,
                _buffer[2],
                _buffer[3],
                0.0,
                0.0,
                0.0,
                0.0,
                1.0,
                0.0,
                _buffer[4],
                _buffer[5],
                0.0,
                1.0
            ]
        }
    }
    
    public init() {
        self._buffer = [1.0, 0.0, 0.0, 1.0, 0.0, 0.0]
    }
    
    public init(clone copy: Mat2D) {
        _buffer = copy.values
    }
    
    // Equatable Protocol
    public static func == (lhs: Mat2D, rhs: Mat2D) -> Bool {
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
    
    static func fromRotation(_ o: Mat2D, _ rad: Float32) {
        let s = sin(rad)
        let c = cos(rad)
        o[0] = c
        o[1] = s
        o[2] = -s
        o[3] = c
        o[4] = 0.0
        o[5] = 0.0
    }
    
    static func copy(_ o: Mat2D, _ f: Mat2D) {
        o[0] = f[0]
        o[1] = f[1]
        o[2] = f[2]
        o[3] = f[3]
        o[4] = f[4]
        o[5] = f[5]
    }
    
    static func scale(_ o: Mat2D, _ a: Mat2D, _ v: Vec2D) {
        let a0 = a[0],
        a1 = a[1],
        a2 = a[2],
        a3 = a[3],
        a4 = a[4],
        a5 = a[5],
        v0 = v[0],
        v1 = v[1]
        o[0] = a0 * v0
        o[1] = a1 * v0
        o[2] = a2 * v1
        o[3] = a3 * v1
        o[4] = a4
        o[5] = a5
    }
    
    static func multiply(_ o: Mat2D, _ a: Mat2D, _ b: Mat2D) {
        let a0 = a[0],
        a1 = a[1],
        a2 = a[2],
        a3 = a[3],
        a4 = a[4],
        a5 = a[5],
        b0 = b[0],
        b1 = b[1],
        b2 = b[2],
        b3 = b[3],
        b4 = b[4],
        b5 = b[5]
        o[0] = a0 * b0 + a2 * b1
        o[1] = a1 * b0 + a3 * b1
        o[2] = a0 * b2 + a2 * b3
        o[3] = a1 * b2 + a3 * b3
        o[4] = a0 * b4 + a2 * b5 + a4
        o[5] = a1 * b4 + a3 * b5 + a5
    }
    
    static func cCopy(_ o: Mat2D, _ a: Mat2D) {
        o[0] = a[0]
        o[1] = a[1]
        o[2] = a[2]
        o[3] = a[3]
        o[4] = a[4]
        o[5] = a[5]
    }
    
    static func invert(_ o: Mat2D, _ a: Mat2D) -> Bool {
        let aa = a[0], ab = a[1], ac = a[2], ad = a[3], atx = a[4], aty = a[5]
        
        var det = aa * ad - ab * ac
        if (det == 0.0) {
            return false
        }
        det = 1.0 / det
        
        o[0] = ad * det
        o[1] = -ab * det
        o[2] = -ac * det
        o[3] = aa * det
        o[4] = (ac * aty - ad * atx) * det
        o[5] = (ab * atx - aa * aty) * det
        return true
    }
    
    static func getScale(_ m: Mat2D, _ s: Vec2D) {
        var x = m[0]
        var y = m[1]
        let xSign : Float32 = x < 0 ? -1.0 : (x > 0) ? 1.0 : 0.0
        s[0] = xSign * sqrt(x * x + y * y)
    
        x = m[2]
        y = m[3]
        let ySign : Float32 = y < 0 ? -1.0 : (y > 0) ? 1.0 : 0.0
        s[1] = ySign * sqrt(x * x + y * y)
    }
    
    static func identity(_ mat: Mat2D) {
        mat[0] = 1.0
        mat[1] = 0.0
        mat[2] = 0.0
        mat[3] = 1.0
        mat[4] = 0.0
        mat[5] = 0.0
    }
    
    static func decompose(_ m: Mat2D, _ result: TransformComponents) {
        let m0 = m[0], m1 = m[1], m2 = m[2], m3 = m[3]
    
        let rotation = atan2(m1, m0)
        let denom = m0 * m0 + m1 * m1
        let scaleX = sqrt(denom)
        let scaleY = (m0 * m3 - m2 * m1) / scaleX
        let skewX = atan2(m0 * m2 + m1 * m3, denom)
    
        result[0] = m[4]
        result[1] = m[5]
        result[2] = scaleX
        result[3] = scaleY
        result[4] = rotation
        result[5] = skewX
    }
    
    static func compose(_ m: Mat2D, _ result: TransformComponents) {
        let r = result[4]
    
        if (r != 0.0) {
            Mat2D.fromRotation(m, r)
        } else {
            Mat2D.identity(m)
        }
        m[4] = result[0]
        m[5] = result[1]
        Mat2D.scale(m, m, result.scale)
    
        let sk = result[5]
        if (sk != 0.0) {
            m[2] = m[0] * sk + m[2]
            m[3] = m[1] * sk + m[3]
        }
    }
    
    public var description: String {
        var res = ""
        
        let cols = 3
        let rows = 2
        
        for i in 0..<rows {
            for j in 0..<cols {
                res += String(_buffer[i * cols + j])
            }
        }
        
        return res
    }
    
}
