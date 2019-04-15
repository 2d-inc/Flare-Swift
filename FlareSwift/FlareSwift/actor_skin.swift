//
//  actor_skin.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/19/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class ActorSkin: ActorComponent {
    var _boneMatrices: [Float32]!
    
    var boneMatrices: [Float32] {
        return _boneMatrices
    }
    
    override func onDirty(_ dirt: UInt8) {
        // Intentionally empty. Doesn't throw dirt around.
    }
    
    override func update(dirt: UInt8) {
        let skinnable = parent as! ActorSkinnable
        
        if skinnable.isConnectedToBones {
            let connectedBones = skinnable.connectedBones
            let length = (connectedBones!.count + 1) * 6
            if _boneMatrices == nil || _boneMatrices.count != length {
                _boneMatrices = Array<Float32>(repeating: 0.0, count: length)
                // First bone transform is always identity.
                _boneMatrices[0] = 1.0;
//                _boneMatrices[1] = 0.0;
//                _boneMatrices[2] = 0.0;
                _boneMatrices[3] = 1.0;
//                _boneMatrices[4] = 0.0;
//                _boneMatrices[5] = 0.0;
            }
            
            var bidx = 6; // Start after first identity.
            
            let mat = Mat2D();
            
            for cb in connectedBones! {
                if cb.node == nil {
                    _boneMatrices[bidx] = 1.0
                    bidx += 1
                    _boneMatrices[bidx] = 0.0
                    bidx += 1
                    _boneMatrices[bidx] = 0.0
                    bidx += 1
                    _boneMatrices[bidx] = 1.0
                    bidx += 1
                    _boneMatrices[bidx] = 0.0
                    bidx += 1
                    _boneMatrices[bidx] = 0.0
                    bidx += 1
                    continue;
                }
                
                Mat2D.multiply(mat, cb.node!.worldTransform, cb.inverseBind);
                
                _boneMatrices[bidx] = mat[0]
                bidx += 1
                _boneMatrices[bidx] = mat[1]
                bidx += 1
                _boneMatrices[bidx] = mat[2]
                bidx += 1
                _boneMatrices[bidx] = mat[3]
                bidx += 1
                _boneMatrices[bidx] = mat[4]
                bidx += 1
                _boneMatrices[bidx] = mat[5]
                bidx += 1
            }
        }
        
        skinnable.invalidateDrawable()
    }
    
    override func completeResolve() {
        let skinnable = parent as! ActorSkinnable
        
        skinnable.skin = self
        _ = artboard!.addDependency(self, skinnable as! ActorComponent)
        if skinnable.isConnectedToBones {
            let connectedBones = skinnable.connectedBones
            for skinnedBone in connectedBones! {
                _ = artboard!.addDependency(self, skinnedBone.node!)
                
                if let constraints = skinnedBone.node!.allConstraints {
                    for constraint in constraints {
                        _ = artboard!.addDependency(self, constraint)
                    }
                }
            }
        }
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instance = ActorSkin()
        instance.copyComponent(self, resetArtboard)
        return instance
    }    
}
