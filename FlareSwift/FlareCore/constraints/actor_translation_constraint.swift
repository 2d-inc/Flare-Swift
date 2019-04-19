//
//  actor_translation_constraint.swift
//  FlareCore
//
//  Created by Umberto Sonnino on 2/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class ActorTranslationConstraint: ActorAxisConstraint {
    override init() {}
    
    func readTranslationConstraint(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readAxisConstraint(artboard, reader)
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let node = ActorTranslationConstraint()
        node.copyAxisConstraint(self, resetArtboard)
        return node
    }
    
    override func constrain(_ node: ActorNode) {
        let t = self.target as? ActorNode
        let p = self.parent!
        let grandParent = p.parent
        
        let transformA = p.worldTransform
        let translationA = Vec2D(fromValues: transformA[4], transformA[5])
        let translationB = Vec2D()
        
        if (t == nil) {
            Vec2D.copy(translationB, translationA)
        } else {
            let transformB = Mat2D(clone: t!.worldTransform)
            if (self.sourceSpace == TransformSpace.Local) {
                if let sourceGrandParent = t!.parent {
                    let inverse = Mat2D()
                    _ = Mat2D.invert(inverse, sourceGrandParent.worldTransform)
                    Mat2D.multiply(transformB, inverse, transformB)
                }
            }
            translationB[0] = transformB[4]
            translationB[1] = transformB[5]
            
            if (!self.copyX) {
                translationB[0] =
                    destSpace == TransformSpace.Local ? 0.0 : translationA[0]
            } else {
                translationB[0] *= Float(self.scaleX)
                if (self.offset) {
                    translationB[0] += p.translation[0]
                }
            }
            
            if (!self.copyY) {
                translationB[1] =
                    destSpace == TransformSpace.Local ? 0.0 : translationA[1]
            } else {
                translationB[1] *= Float(self.scaleY)
                if (self.offset) {
                    translationB[1] += p.translation[1]
                }
            }
            
            if (destSpace == TransformSpace.Local) {
                if (grandParent != nil) {
                    _ = Vec2D.transformMat2D(translationB, translationB, grandParent!.worldTransform)
                }
            }
        }
        
        let clampLocal = (minMaxSpace == TransformSpace.Local && grandParent != nil)
        if (clampLocal) {
            // Apply min max in local space, so transform to local coordinates first.
            let temp = Mat2D()
            _ = Mat2D.invert(temp, grandParent!.worldTransform)
            // Get our target world coordinates in parent local.
            _ = Vec2D.transformMat2D(translationB, translationB, temp)
        }
        let fMaxX = Float(maxX)
        if (self.enableMaxX && translationB[0] > fMaxX) {
            translationB[0] = fMaxX
        }
        let fMinX = Float(minX)
        if (self.enableMinX && translationB[0] < fMinX) {
            translationB[0] = fMinX
        }
        let fMaxY = Float(maxY)
        if (self.enableMaxY && translationB[1] > fMaxY) {
            translationB[1] = fMaxY
        }
        let fMinY = Float(minY)
        if (self.enableMinY && translationB[1] < fMinY) {
            translationB[1] = fMinY
        }
        if (clampLocal) {
            // Transform back to world.
            _ = Vec2D.transformMat2D(translationB, translationB, grandParent!.worldTransform)
        }
        
        let fStrength = Float(self.strength)
        let ti = 1.0 - fStrength
        
        // Just interpolate world translation
        transformA[4] = translationA[0] * ti + translationB[0] * fStrength
        transformA[5] = translationA[1] * ti + translationB[1] * fStrength
    }
    
    override func update(dirt: UInt8) {}
    override func completeResolve() {}
}
