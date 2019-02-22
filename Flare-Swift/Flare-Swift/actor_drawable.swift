//
//  actor_drawable.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/14/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

enum BlendModes {
    case Normal, Multiply, Screen, Additive
}

protocol ActorDrawable {
    // Editor set draw index.
    var _drawOrder: Int { get set }
    var drawOrder: Int { get set }
    // Computed draw index in the draw list.
    var drawIndex: Int { get set }
    func computeAABB() -> AABB
    func initializeGraphics()
}
