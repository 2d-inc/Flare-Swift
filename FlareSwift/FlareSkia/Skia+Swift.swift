//
//  Skia+Swift.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 4/1/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

/*
 
This macro assumes all arguments are >=0 and <=255.
#define sk_color_set_argb(a, r, g, b)   (((a) << 24) | ((r) << 16) | ((g) << 8) | (b))
#define sk_color_get_a(c)               (((c) >> 24) & 0xFF)
#define sk_color_get_r(c)               (((c) >> 16) & 0xFF)
#define sk_color_get_g(c)               (((c) >>  8) & 0xFF)
#define sk_color_get_b(c)               (((c) >>  0) & 0xFF)
*/

import Skia

@inline(__always) func sk_color_set_argb(_ a: UInt32, _ r: UInt32, _ g: UInt32, _ b: UInt32) -> sk_color_t {
    return (((a) << 24) | ((r) << 16) | ((g) << 8) | (b))
}

@inline(__always) func sk_color_get_a(_ c: UInt32) -> UInt32 {
    return (((c) >> 24) & 0xFF)
}

@inline(__always) func sk_color_get_r(_ c: UInt32) -> UInt32 {
    return (((c) >> 16) & 0xFF)
}

@inline(__always) func sk_color_get_g(_ c: UInt32) -> UInt32 {
    return (((c) >> 8) & 0xFF)
}

@inline(__always) func sk_color_get_b(_ c: UInt32) -> UInt32 {
    return (((c) >> 0) & 0xFF)
}

@inline(__always) func sk_color_white() -> UInt32 {
    return sk_color_set_argb(255, 255, 255, 255)
}

@inline(__always) func getStrokeCap(cap: StrokeCap) -> sk_stroke_cap_t {
    switch cap {
    case .Butt:
        return BUTT_SK_STROKE_CAP
    case .Round:
        return ROUND_SK_STROKE_CAP
    case .Square:
        return SQUARE_SK_STROKE_CAP
    }
}

@inline(__always) func getStrokeJoin(cap: StrokeJoin) -> sk_stroke_join_t {
    switch cap {
    case .Miter:
        return MITER_SK_STROKE_JOIN
    case .Round:
        return ROUND_SK_STROKE_JOIN
    case .Bevel:
        return BEVEL_SK_STROKE_JOIN
    }
}

/**
 SkPath wraps the `sk_path_t` C-style pointer and conform to the ConcretePath protocol.
 */
class SkPath: ConcretePath {
    private var _skPath: OpaquePointer
    
    var skPath: OpaquePointer {
        return _skPath
    }

    required init() {
        _skPath = sk_path_new()
    }
    
    func moveTo(_ to: Vec2D) {
        sk_path_move_to(_skPath, to.x, to.y)
    }
    
    func lineTo(_ to: Vec2D) {
        sk_path_line_to(_skPath, to.x, to.y)
    }
    
    func curveTo(_ to: Vec2D, control1: Vec2D, control2: Vec2D) {
        sk_path_cubic_to(_skPath, control1.x, control1.y, control2.x, control2.y, to.x, to.y)
    }
    
    func addPath(_ subpath: ConcretePath, mat: Mat2D) {
        var skMat = sk_matrix_t(
            mat: (
                mat[0],
                mat[1],
                0.0,
                mat[2],
                mat[3],
                0.0,
                mat[4],
                mat[5],
                1.0
            )
        )
        let matPointer = withUnsafeMutablePointer(to: &skMat){
            UnsafeMutablePointer($0)
        }
        sk_path_add_path_with_matrix(_skPath, (subpath as! SkPath)._skPath, 0, 0, matPointer)
    }
}
