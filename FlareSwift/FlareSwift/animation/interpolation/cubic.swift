//
//  cubic.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/18/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

import Foundation

class CubicInterpolator: Interpolator {
    var _cubic: CubicEase!
    static let _instance = CubicInterpolator()
    
    class var instance: CubicInterpolator {
        return _instance
    }
    
    func getEasedMix(mix: Double) -> Double {
        return _cubic.ease(t: mix)
    }
    
    func read(_ reader: StreamReader) -> Bool {
        _cubic = EaseFactory.make(
            x1: Double(reader.readFloat32(label: "cubicX1")),
            y1: Double(reader.readFloat32(label: "cubicY1")),
            x2: Double(reader.readFloat32(label: "cubicX2")),
            y2: Double(reader.readFloat32(label: "cubicY2"))
        )
        return true
    }
}
