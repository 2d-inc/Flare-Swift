//
//  keyframe_transformations.swift
//  FlareCore
//
//  Created by Umberto Sonnino on 2/18/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

// KeyFrames for Translation, Scale and Rotation

class KeyFramePosX: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Float, _ mix: Float) {
        let node = component as! ActorNode
        let x = node.x
        node.x = x * (1.0 - mix) + value * mix
    }
}

class KeyFramePosY: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Float, _ mix: Float) {
        let node = component as! ActorNode
        let y = node.y
        node.y = y * (1.0 - mix) + value * mix
    }
}

class KeyFrameScaleX: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Float, _ mix: Float) {
        let node = component as! ActorNode
        let scaleX = node.scaleX
        node.scaleX = scaleX * (1.0 - mix) + value * mix
    }
}

class KeyFrameScaleY: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Float, _ mix: Float) {
        let node = component as! ActorNode
        let scaleY = node.scaleY
        node.scaleY = scaleY * (1.0 - mix) + value * mix
    }
}

class KeyFrameRotation: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Float, _ mix: Float) {
        let node = component as! ActorNode
        node.rotation = Double(Float(node.rotation) * (1.0 - mix) + value * mix)
    }
}

