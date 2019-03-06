//
//  actor_jelly_bone.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 3/6/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class ActorJellyBone: ActorBoneBase {
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceNode = ActorJellyBone()
        instanceNode.copyBoneBase(self, resetArtboard)
        return instanceNode
    }
    
    func readJellyBone(_ artboard: ActorArtboard, _ reader: StreamReader) {
        // The Jelly Bone has a specialized read that doesn't go down the typical node path, this is because majority of the transform properties
        // of the Jelly Bone are controlled by the Jelly Controller and are unnecessary for serialization.
        self.readComponent(artboard, reader)
        self.opacity = Double(reader.readFloat32(label: "opacity"))
        self.collapsedVisibility = reader.readBool(label: "isCollapsed")
    }
}
