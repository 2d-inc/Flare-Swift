//
//  linear.swift
//  Flare
//
//  Created by Umberto Sonnino on 2/18/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class LinearInterpolator: Interpolator {
    
    static let _instance = LinearInterpolator()
    
    class var instance: LinearInterpolator {
        return _instance
    }
    
    func getEasedMix(mix: Float) -> Float {
        return mix
    }
}

