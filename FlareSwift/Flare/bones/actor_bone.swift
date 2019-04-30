//
//  actor_bone.swift
//  Flare
//
//  Created by Umberto Sonnino on 3/6/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation


class ActorBone: ActorBoneBase {
    var _firstBone: ActorBone?
    var jelly: JellyComponent?
    
    var firstBone: ActorBone? {
        return _firstBone
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceNode = ActorBone()
        instanceNode.copyBoneBase(self, resetArtboard)
        return instanceNode
    }
    
    override func completeResolve() {
        super.completeResolve();
        if let c = children {
            for node in c {
                if let n = node as? ActorBone {
                    _firstBone = n
                    return
                }
            }
        }
    }
    
    func readActorBone(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readBoneBase(artboard, reader)
    }
}
