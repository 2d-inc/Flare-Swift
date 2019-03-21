//
//  flare_drawable.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 3/19/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

protocol FlareDrawable: class {
//    func draw(context: CGContext)
    func draw(on: CALayer)
    // TODO: Blending
}
