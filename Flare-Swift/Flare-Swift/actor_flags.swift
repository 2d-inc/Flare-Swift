//
//  actor_flags.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/12/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class ActorFlags {
    static let IsClean: UInt8 = 0
    static let IsDrawOrderDirty: UInt8 = 1 << 0
    static let IsVertexDeformDirty: UInt8 = 1 << 1
    static let IsDirty: UInt8 = 1 << 0
}

class DirtyFlags {
    static let TransformDirty: UInt8 = 1 << 0
    static let WorldTransformDirty: UInt8 = 1 << 1
    static let PaintDirty: UInt8 = 1 << 2
}

/**
 As tested in Playground:
 
 var flags: ActorFlags = [.IsDrawOrderDirty]
 flags.rawValue // 1
 let union = flags.union(ActorFlags.IsDirty)
 union.rawValue // 5
 union.contains(ActorFlags.IsDrawOrderDirty) // true
 union.contains(ActorFlags.IsVertexDeformDirty) // false
 union.contains(ActorFlags.IsDirty) // true
 flags.contains(ActorFlags.IsVertexDeformDirty) // false

 var flags2 : ActorFlags = []
 flags2.insert(.IsDirty) // inserted: true, rawValue: 4
 flags2.remove(.IsDirty) // returns flags2 with rawValue: 0
 flags2.rawValue // 0

 */
