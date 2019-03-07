//
//  bezier_slice.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 3/7/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class BezierSlice {
    let subcurve: Bezier
    let t1: Float
    let t2: Float
    
    init(_ subcurve: Bezier,_ t1: Float, _ t2: Float) {
        self.subcurve = subcurve
        self.t1 = t1
        self.t2 = t2
    }
}
