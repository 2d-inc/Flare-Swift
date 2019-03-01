//
//  keyframe_constraint.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/18/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class KeyFrameConstraintStrength: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Double, _ mix: Double) {
        let constraint = component as! ActorConstraint
        constraint.strength = constraint.strength * (1.0 - mix) + value * mix
    }
}
