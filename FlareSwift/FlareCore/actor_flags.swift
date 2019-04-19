//
//  actor_flags.swift
//  FlareCore
//
//  Created by Umberto Sonnino on 2/12/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class ActorFlags {
    static let IsClean: UInt8 = 0
    static let IsDrawOrderDirty: UInt8 = 1 << 0
    static let IsVertexDeformDirty: UInt8 = 1 << 1
    static let IsDirty: UInt8 = 1 << 1
}

class DirtyFlags {
    static let TransformDirty: UInt8 = 1 << 0
    static let WorldTransformDirty: UInt8 = 1 << 1
    static let PaintDirty: UInt8 = 1 << 2
}
