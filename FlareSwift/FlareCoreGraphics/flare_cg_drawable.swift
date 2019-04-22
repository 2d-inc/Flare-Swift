//
//  flare_cg_drawable.swift
//  FlareCoreGraphics
//
//  Created by Umberto Sonnino on 3/19/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

protocol FlareCGDrawable: class {
    var _layer: CALayer { get set }
    func addLayer(on: CALayer)
    func draw(on: CALayer)
    // TODO: Blending
}
