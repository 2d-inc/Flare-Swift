//
//  actor_skinnable.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/19/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class SkinnedBone {
    var boneIdx: Int = 0
    var node: ActorNode?
    var bind: Mat2D = Mat2D()
    var inverseBind = Mat2D()
}

public class ActorSkinnable: ActorNode {
    var _connectedBones: [SkinnedBone]?
    
    var connectedBones: [SkinnedBone]? {
        return _connectedBones
    }
    
    var isConnectedToBones: Bool {
        guard let cb = _connectedBones else {
            return false
        }
        return !cb.isEmpty
    }
    
    func readSkinnable(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readNode(artboard, reader)
        
        reader.openArray(label: "bones")
        let numConnectedBones = Int(reader.readUint8Length())
        if numConnectedBones != 0 {
            self._connectedBones = Array<SkinnedBone>()
            
            for i in 0 ..< numConnectedBones {
                let bc = SkinnedBone()
                reader.openObject(label: "bone")
                bc.boneIdx = reader.readId(label: "component")
                reader.readFloat32ArrayOffset(ar: &bc.bind.values, length: 6, offset: 0, label: "bind")
                reader.closeObject()
                _ = Mat2D.invert(bc.inverseBind, bc.bind)
                self._connectedBones?.insert(bc, at: i)
            }
            reader.closeArray()
            let worldOverride = Mat2D()
            reader.readFloat32ArrayOffset(ar: &worldOverride.values, length: 6, offset: 0, label: "worldTransform")
            self.worldTransformOverride = worldOverride
        } else {
            reader.closeArray()
        }
    }
    
    override func resolveComponentIndices(_ components: [ActorComponent?]) {
        super.resolveComponentIndices(components)
        
        if let cb = _connectedBones {
            for i in 0 ..< cb.count {
                let bc = cb[i]
                bc.node = (components[bc.boneIdx] as! ActorNode)
            }
        }
    }
    
    func copySkinnable(_ node: ActorSkinnable, _ resetArtboard: ActorArtboard) {
        copyNode(node, resetArtboard)
        
        if let cb = node._connectedBones {
            _connectedBones = [SkinnedBone]()
            for i in 0 ..< cb.count {
                let from = cb[i]
                let bc = SkinnedBone()
                bc.boneIdx = from.boneIdx
                Mat2D.copy(bc.bind, from.bind)
                Mat2D.copy(bc.inverseBind, from.inverseBind)
                _connectedBones?.insert(bc, at: i)
            }
        }
    }
}
