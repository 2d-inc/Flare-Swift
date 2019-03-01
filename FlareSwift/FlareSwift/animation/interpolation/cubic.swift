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
    
    static let _instance = CubicInterpolator()
    
    class var instance: CubicInterpolator {
        return _instance
    }
    
    func getEasedMix(mix: Double) -> Double {
        return mix
    }
}
