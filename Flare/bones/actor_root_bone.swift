//
//  actor_root_bone.swift
//  Flare
//
//  Created by Umberto Sonnino on 3/6/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class ActorRootBone: ActorNode {
    var _firstBone: ActorBone?
    
    var firstBone: ActorBone? {
        return _firstBone
    }
    
    override func completeResolve() {
        super.completeResolve()
        if let c = children {
            for node in c {
                if let n = node as? ActorBone {
                    _firstBone = n
                    return
                }
            }
        }
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceNode = ActorRootBone()
        instanceNode.copyNode(self, resetArtboard)
        return instanceNode
    }

    func readRootBone(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readNode(artboard, reader)
    }
}

