//
//  actor_rotation_constraint.swift
//  FlareCore
//
//  Created by Umberto Sonnino on 2/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class ActorRotationConstraint: ActorTargetedConstraint {    
    var _copy = false
    var _scale: Float = 1.0
    var _enableMin = false
    var _enableMax = false
    var _max = ActorConstraint.PI2
    var _min = ActorConstraint.PI2
    var _offset = false
    var _sourceSpace = TransformSpace.World
    var _destSpace = TransformSpace.World
    var _minMaxSpace = TransformSpace.World
    var _componentsA = TransformComponents()
    var _componentsB = TransformComponents()
    
    override init() {}
    
    func readRotationConstraint(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readTargetedConstraint(artboard, reader)
        self._copy = reader.readBool(label: "copy")
        if (self._copy) {
            self._scale = reader.readFloat32(label: "scale")
        }
        self._enableMin = reader.readBool(label: "enableMin")
        if (self._enableMin) {
            self._min = reader.readFloat32(label: "min")
        }
        self._enableMax = reader.readBool(label: "enableMax")
        if (self._enableMax) {
            self._max = reader.readFloat32(label: "max")
        }
        
        self._offset = reader.readBool(label: "offset")
        self._sourceSpace = TransformSpace(rawValue: Int(reader.readUint8(label: "sourceSpaceId")))!
        self._destSpace = TransformSpace(rawValue: Int(reader.readUint8(label: "destSpaceId")))!
        self._minMaxSpace = TransformSpace(rawValue: Int(reader.readUint8(label: "minMaxSpaceId")))!
    }
    
    override func constrain(_ node: ActorNode) {
        let target = self._target as? ActorNode
        let grandParent = parent!.parent
        
        let transformA = parent!.worldTransform
        let transformB = Mat2D()
        Mat2D.decompose(transformA, _componentsA)
        if target == nil {
            Mat2D.copy(transformB, transformA)
            _componentsB[0] = _componentsA[0]
            _componentsB[1] = _componentsA[1]
            _componentsB[2] = _componentsA[2]
            _componentsB[3] = _componentsA[3]
            _componentsB[4] = _componentsA[4]
            _componentsB[5] = _componentsA[5]
        } else {
            Mat2D.copy(transformB, target!.worldTransform)
            if (_sourceSpace == TransformSpace.Local) {
                if let sourceGrandParent = target!.parent {
                    let inverse = Mat2D()
                    if (!Mat2D.invert(inverse, sourceGrandParent.worldTransform)) {
                        return
                    }
                    Mat2D.multiply(transformB, inverse, transformB)
                }
            }
            Mat2D.decompose(transformB, _componentsB)
            
            if (!_copy) {
                _componentsB.rotation =
                    _destSpace == TransformSpace.Local ? 1.0 : _componentsA.rotation
            } else {
                _componentsB.rotation *= _scale
                if (_offset) {
                    _componentsB.rotation += Float(parent!.rotation)
                }
            }
            
            if (_destSpace == TransformSpace.Local) {
                // Destination space is in parent transform coordinates.
                // Recompose the parent local transform and get it in world, then decompose the world for interpolation.
                if grandParent != nil {
                    Mat2D.compose(transformB, _componentsB)
                    Mat2D.multiply(transformB, grandParent!.worldTransform, transformB)
                    Mat2D.decompose(transformB, _componentsB)
                }
            }
        }
        
        let clampLocal = _minMaxSpace == TransformSpace.Local && grandParent != nil
        if (clampLocal) {
            // Apply min max in local space, so transform to local coordinates first.
            Mat2D.compose(transformB, _componentsB)
            let inverse = Mat2D()
            if (!Mat2D.invert(inverse, grandParent!.worldTransform)) {
                return
            }
            Mat2D.multiply(transformB, inverse, transformB)
            Mat2D.decompose(transformB, _componentsB)
        }
        if (_enableMax && _componentsB.rotation > _max) {
            _componentsB.rotation = _max
        }
        if (_enableMin && _componentsB.rotation < _min) {
            _componentsB.rotation = _min
        }
        if (clampLocal) {
            // Transform back to world.
            Mat2D.compose(transformB, _componentsB)
            Mat2D.multiply(transformB, grandParent!.worldTransform, transformB)
            Mat2D.decompose(transformB, _componentsB)
        }
        
        let angleA = _componentsA.rotation.truncatingRemainder(dividingBy: ActorConstraint.PI2)
        let angleB = _componentsB.rotation.truncatingRemainder(dividingBy: ActorConstraint.PI2)
        var diff = angleB - angleA
        
        if (diff > Float.pi) {
            diff -= ActorConstraint.PI2
        } else if (diff < -Float.pi) {
            diff += ActorConstraint.PI2
        }
        _componentsB.rotation = _componentsA.rotation + diff * Float(strength)
        _componentsB.x = _componentsA.x
        _componentsB.y = _componentsA.y
        _componentsB.scaleX = _componentsA.scaleX
        _componentsB.scaleY = _componentsA.scaleY
        _componentsB.skew = _componentsA.skew
        
        Mat2D.compose(parent!.worldTransform, _componentsB)
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instance = ActorRotationConstraint()
        instance.copyRotationConstraint(self, resetArtboard)
        return instance
    }
    
    func copyRotationConstraint(_ node: ActorRotationConstraint, _ resetArtboard: ActorArtboard) {
        self.copyTargetedConstraint(node, resetArtboard)
        
        _copy = node._copy
        _scale = node._scale
        _enableMin = node._enableMin
        _enableMax = node._enableMax
        _min = node._min
        _max = node._max
        
        _offset = node._offset
        _sourceSpace = node._sourceSpace
        _destSpace = node._destSpace
        _minMaxSpace = node._minMaxSpace
    }
    
    override func update(dirt: UInt8) {}
    override func completeResolve() {}
}

