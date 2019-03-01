//
//  keyframe_transformations.swift
//  Flare-Swift
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
    
    override func setValue(_ component: ActorComponent, _ value: Double, _ mix: Double) {
        let node = component as! ActorNode
        let x = Double(node.x)
        node.x = Float32(x * (1.0 - mix) + value * mix)
    }
}

class KeyFramePosY: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Double, _ mix: Double) {
        let node = component as! ActorNode
        let y = Double(node.y)
        node.y = Float32(y * (1.0 - mix) + value * mix)
    }
}

class KeyFrameScaleX: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Double, _ mix: Double) {
        let node = component as! ActorNode
        let scaleX = Double(node.scaleX)
        node.scaleX = Float32(scaleX * (1.0 - mix) + value * mix)
    }
}

class KeyFrameScaleY: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Double, _ mix: Double) {
        let node = component as! ActorNode
        let scaleY = Double(node.scaleY)
        node.scaleY = Float32(scaleY * (1.0 - mix) + value * mix)
    }
}

class KeyFrameRotation: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Double, _ mix: Double) {
        let node = component as! ActorNode
        node.rotation = node.rotation * (1.0 - mix) + value * mix
    }
}

