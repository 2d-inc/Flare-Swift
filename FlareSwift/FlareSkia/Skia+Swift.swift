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

@inline(__always) func sk_color_set_argb(_ a: UInt32, _ r: UInt32, _ g: UInt32, _ b: UInt32) -> UInt32 {
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
