//
//  hold.swift
//  Flare
//
//  Created by Umberto Sonnino on 2/18/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

import Foundation

class HoldInterpolator: Interpolator {
    
    static let _instance = HoldInterpolator()
    
    class var instance: HoldInterpolator {
        return _instance
    }
    
    func getEasedMix(mix: Float) -> Float {
        return 0.0
    }
}
