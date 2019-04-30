//
//  keyframe_opacity.swift
//  Flare
//
//  Created by Umberto Sonnino on 2/18/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class KeyFrameOpacity: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Float, _ mix: Float) {
        let node = component as! ActorNode
        node.opacity = Double(Float(node.opacity) * (1.0 - mix) + value * mix)
    }
}

class KeyFramePaintOpacity: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Float, _ mix: Float) {
        let node = component as! ActorPaint
        node.opacity = Double(Float(node.opacity) * (1.0 - mix) + value * mix)
    }
}
