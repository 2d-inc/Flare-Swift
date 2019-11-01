//
//  actor_bone_base.swift
//  Flare
//
//  Created by Umberto Sonnino on 3/6/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class ActorBoneBase: ActorNode {
    var _length: Float = 0
    
    var length: Float {
        get {
            return _length
        }
        set {
            if _length == newValue {
                return
            }
            _length = newValue
            
            if let c = children {
                for node in c {
                    if (node is ActorBone) {
                        node.x = newValue
                    }
                }
            }
            
        }
    }
    
    func getTipWorldTranslation(_ vec: Vec2D ) -> Vec2D {
        let transform = Mat2D()
        transform[4] = _length
        Mat2D.multiply(transform, worldTransform, transform)
        vec[0] = transform[4]
        vec[1] = transform[5]
        return vec
    }
    
    func readBoneBase(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readNode(artboard, reader)
        self._length = reader.readFloat32(label: "length")
    }
    
    func copyBoneBase(_ node: ActorBoneBase, _ resetArtboard: ActorArtboard) {
        super.copyNode(node, resetArtboard)
        _length = node._length
    }
}
