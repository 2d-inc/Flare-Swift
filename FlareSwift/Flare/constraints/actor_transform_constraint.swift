//
//  actor_transform_constraint.swift
//  Flare
//
//  Created by Umberto Sonnino on 2/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class ActorTransformConstraint: ActorTargetedConstraint {
    var _sourceSpace = TransformSpace.World
    var _destSpace = TransformSpace.World
    var _componentsA = TransformComponents()
    var _componentsB = TransformComponents()
    
    override init() {}
    
    func readTransformConstraint(_ artboard: ActorArtboard, _ reader: StreamReader ) {
        self.readTargetedConstraint(artboard, reader)
        self._sourceSpace = TransformSpace(rawValue: Int(reader.readUint8(label: "sourceSpaceId")))!
        self._destSpace = TransformSpace(rawValue: Int(reader.readUint8(label: "destSpaceId")))!
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let node = ActorTransformConstraint()
        node.copyTransformConstraint(self, resetArtboard)
        return node
    }
    
    func copyTransformConstraint(_ node: ActorTransformConstraint, _ resetArtboard: ActorArtboard) {
        self.copyTargetedConstraint(node, resetArtboard)
        self._sourceSpace = node._sourceSpace
        self._destSpace = node._destSpace
    }
    
    override func constrain(_ node: ActorNode) {
        guard let t = self._target as? ActorNode else {
            return
        }
        
        let parent = self.parent!
        
        let transformA = parent.worldTransform
        let transformB = Mat2D(clone: t.worldTransform)
        if (_sourceSpace == TransformSpace.Local) {
            if let grandParent = t.parent {
                let inverse = Mat2D()
                _ = Mat2D.invert(inverse, grandParent.worldTransform)
                Mat2D.multiply(transformB, inverse, transformB)
            }
        }
        if (_destSpace == TransformSpace.Local) {
            if let grandParent = parent.parent {
                Mat2D.multiply(transformB, grandParent.worldTransform, transformB)
            }
        }
        Mat2D.decompose(transformA, _componentsA)
        Mat2D.decompose(transformB, _componentsB)
        
        let angleA = _componentsA[4].remainder(dividingBy: ActorConstraint.PI2)
        let angleB = _componentsB[4].remainder(dividingBy: ActorConstraint.PI2)
        var diff = angleB - angleA
        if (diff > Float.pi) {
            diff -= ActorConstraint.PI2
        } else if (diff < -Float.pi) {
            diff += ActorConstraint.PI2
        }
        
        let fStrength = Float(self.strength)
        let ti = 1.0 - fStrength
        
        _componentsB[4] = angleA + diff * fStrength
        _componentsB[0] = _componentsA[0] * ti + _componentsB[0] * fStrength
        _componentsB[1] = _componentsA[1] * ti + _componentsB[1] * fStrength
        _componentsB[2] = _componentsA[2] * ti + _componentsB[2] * fStrength
        _componentsB[3] = _componentsA[3] * ti + _componentsB[3] * fStrength
        _componentsB[5] = _componentsA[5] * ti + _componentsB[5] * fStrength
        
        Mat2D.compose(parent.worldTransform, _componentsB)
    }
    
    override func update(dirt: UInt8) {}
    override func completeResolve() {}
}
