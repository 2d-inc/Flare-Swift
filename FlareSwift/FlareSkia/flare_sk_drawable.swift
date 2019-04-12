//
//  flare_sk_drawable.swift
//  FlareSkia
//
//  Created by Umberto Sonnino on 3/19/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

protocol FlareSkDrawable: class {
    func draw(_ skCanvas: OpaquePointer)
    // TODO: Blending
}
