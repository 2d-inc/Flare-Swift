//
//  actor_scale_constraint.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class ActorScaleConstraint: ActorAxisConstraint {
    var _componentsA = TransformComponents()
    var _componentsB = TransformComponents()
    
    override init() {}
    
    func readScaleConstraint(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readAxisConstraint(artboard, reader)
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let node = ActorScaleConstraint()
        node.copyAxisConstraint(self, resetArtboard)
        return node
    }
    
    override func constrain(_ node: ActorNode) {
        let t = self.target as? ActorNode
        let p = self.parent!
        let grandParent = p.parent
        
        let transformA = p.worldTransform
        let transformB = Mat2D()
        Mat2D.decompose(transformA, _componentsA)
        if t == nil {
            Mat2D.copy(transformB, transformA)
            _componentsB[0] = _componentsA[0]
            _componentsB[1] = _componentsA[1]
            _componentsB[2] = _componentsA[2]
            _componentsB[3] = _componentsA[3]
            _componentsB[4] = _componentsA[4]
            _componentsB[5] = _componentsA[5]
        } else {
            Mat2D.copy(transformB, t!.worldTransform)
            if sourceSpace == TransformSpace.Local {
                if let sourceGrandParent = t!.parent {
                    let inverse = Mat2D()
                    _ = Mat2D.invert(inverse, sourceGrandParent.worldTransform)
                    Mat2D.multiply(transformB, inverse, transformB)
                }
            }
            Mat2D.decompose(transformB, _componentsB)
            
            if !self.copyX {
                _componentsB[2] = self.destSpace == TransformSpace.Local ? 1.0 : _componentsA[2]
            } else {
                _componentsB[2] *= Float(self.scaleX)
                if self.offset {
                    _componentsB[2] *= Float(parent!.scaleX)
                }
            }
            
            if !self.copyY {
                _componentsB[3] = self.destSpace == TransformSpace.Local ? 0.0 : _componentsA[3]
            } else {
                _componentsB[3] *= Float(self.scaleY)
                
                if self.offset {
                    _componentsB[3] *= Float(p.scaleY)
                }
            }
            
            if destSpace == TransformSpace.Local {
                // Destination space is in parent transform coordinates.
                // Recompose the parent local transform and get it in world, then decompose the world for interpolation.
                if grandParent != nil {
                    Mat2D.compose(transformB, _componentsB)
                    Mat2D.multiply(transformB, grandParent!.worldTransform, transformB)
                    Mat2D.decompose(transformB, _componentsB)
                }
            }
        }
        
        let clampLocal = (minMaxSpace == TransformSpace.Local && grandParent != nil)
        if clampLocal {
            // Apply min max in local space, so transform to local coordinates first.
            Mat2D.compose(transformB, _componentsB)
            let inverse = Mat2D()
            _ = Mat2D.invert(inverse, grandParent!.worldTransform)
            Mat2D.multiply(transformB, inverse, transformB)
            Mat2D.decompose(transformB, _componentsB)
        }
        let fMaxX = Float(maxX)
        if self.enableMaxX && _componentsB[2] > fMaxX {
            _componentsB[2] = fMaxX
        }
        let fMinX = Float(minX)
        if self.enableMinX && _componentsB[2] < fMinX {
            _componentsB[2] = fMinX
        }
        let fMaxY = Float(maxY)
        if self.enableMaxY && _componentsB[3] > fMaxY {
            _componentsB[3] = fMaxY
        }
        let fMinY = Float(minY)
        if self.enableMinY && _componentsB[3] < fMinY {
            _componentsB[3] = fMinY
        }
        if clampLocal {
            // Transform back to world.
            Mat2D.compose(transformB, _componentsB)
            Mat2D.multiply(transformB, grandParent!.worldTransform, transformB)
            Mat2D.decompose(transformB, _componentsB)
        }
        
        let fStrength = Float(self.strength)
        let ti = 1.0 - fStrength
        
        _componentsB[4] = _componentsA[4]
        _componentsB[0] = _componentsA[0]
        _componentsB[1] = _componentsA[1]
        _componentsB[2] = _componentsA[2] * ti + _componentsB[2] * fStrength
        _componentsB[3] = _componentsA[3] * ti + _componentsB[3] * fStrength
        _componentsB[5] = _componentsA[5]
        
        Mat2D.compose(p.worldTransform, _componentsB)
    }
    
    override func update(dirt: UInt8) {}
    override func completeResolve() {}
}
