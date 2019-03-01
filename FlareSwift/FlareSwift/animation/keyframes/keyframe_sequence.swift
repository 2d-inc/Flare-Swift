//
//  keyframe_sequence.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class KeyFrameSequence: KeyFrameNumeric {
    override func read(_ reader: StreamReader) -> Bool {
        if super.read(reader) {
            return true
        }
        return false
    }
    
    override func setValue(_ component: ActorComponent, _ value: Double, _ mix: Double) {
        let node = component as! ActorImage
        var frameIndex = Int(floor(value)) % node.sequenceFrames!.count
        if frameIndex < 0 {
            frameIndex += node.sequenceFrames!.count
        }
        node.sequenceFrame = frameIndex
    }
}
