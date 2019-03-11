//
//  interpolator.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/18/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

protocol Interpolator {
    func getEasedMix(mix: Float) -> Float
}
