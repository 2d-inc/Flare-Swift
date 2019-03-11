//
//  keyframe_shape.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class KeyFrameShapeWidth: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Float, _ mix: Float) {
        let shape = component as! ActorProceduralPath
        shape.width = Double(Float(shape.width) * (1.0 - mix) + value * mix)
    }
}

class KeyFrameShapeHeight: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Float, _ mix: Float) {
        let shape = component as! ActorProceduralPath
        shape.height = Double(Float(shape.height) * (1.0 - mix) + value * mix)
    }
}
