//
//  keyframe_radius.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class KeyFrameCornerRadius: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Float, _ mix: Float) {
        let rect = component as! ActorRectangle
        rect.radius = Double(Float(rect.radius) * (1.0 - mix) + value * mix)
    }
}

class KeyFrameInnerRadius: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Float, _ mix: Float) {
        let rect = component as! ActorStar
        rect.innerRadius = Double(Float(rect.innerRadius) * (1.0 - mix) + value * mix)
    }
}
