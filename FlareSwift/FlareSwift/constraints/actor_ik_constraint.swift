//
//  actor_ik_constraint.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class InfluencedBone {
    var boneIdx: Int
    var bone: ActorBone?
    
    init(boneIndex: Int) {
        self.boneIdx = boneIndex
    }
}

class BoneChain {
    var index: Int
    var bone: ActorBone
    var included: Bool
    var angle: Float = 0.0
    var transformComponents = TransformComponents()
    var parentWorldInverse = Mat2D()
    
    init(index: Int, bone: ActorBone, included: Bool) {
        self.index = index
        self.bone = bone
        self.included = included
    }
}

class ActorIKConstraint: ActorTargetedConstraint {
    var _invertDirection = false
    var _influencedBones: Array<InfluencedBone>!
    var _fkChain: Array<BoneChain>!
    var _boneData: Array<BoneChain>!
    
    override func resolveComponentIndices(_ components: [ActorComponent?]) {
        super.resolveComponentIndices(components)
        
        if (_influencedBones != nil) {
            for influenced in _influencedBones {
                influenced.bone = (components[influenced.boneIdx] as! ActorBone)
                // Mark peer constraints, N.B. that we're not adding it to the parent bone
                // as we're constraining it anyway.
                if (influenced.bone != parent) {
                    _ = influenced.bone!.addPeerConstraint(constraint: self)
                }
            }
        }
    }
    
    override func completeResolve() {
        guard (_influencedBones != nil || _influencedBones.count >= 0) else {
            return
        }
        
        // Initialize solver.
        let start = _influencedBones[0].bone
        var end = _influencedBones[_influencedBones.count - 1].bone
        var count = 0
        while (end != nil && end != start?.parent) {
            count += 1
            end = end!.parent as? ActorBone
        }
        
        let allIn = count < 3
        end = _influencedBones[_influencedBones.count - 1].bone
        _fkChain = Array<BoneChain>()
//        _fkChain.reserveCapacity(count)
        var idx = count - 1
        while (end != nil && end != start?.parent) {
            let bc = BoneChain(index: idx, bone: end!, included: allIn)
//            _fkChain![idx] = bc
            _fkChain.insert(bc, at: 0)
            idx -= 1
            end = end!.parent as? ActorBone
        }
        
        // Make sure bones are good.
        _boneData = Array<BoneChain>()
        for bone in _influencedBones {
//            let item = _fkChain.firstWhere( (chainItem) => chainItem.bone == bone.bone, orElse: () => nil)
            if let item = _fkChain.first(where: { $0.bone == bone.bone } ) {
                _boneData.append(item)
            }
            else {
                print("Bone not in chain: \(bone.bone!.name)")
            }
        }
        if (!allIn) {
            // Influenced bones are in the IK chain.
            for i in 0 ..< _boneData.count {
                let item = _boneData[i]
                item.included = true
                _fkChain[item.index + 1].included = true
            }
        }
        
        // Finally mark dependencies.
        for bone in _influencedBones {
            // Don't mark dependency on parent as ActorComponent already does this.
            if (bone.bone == parent) {
                continue
            }
            _ = artboard!.addDependency(self, bone.bone!)
        }
        
        if (target != nil) {
            _ = artboard!.addDependency(self, target!)
        }
        
        // All the first level children of the influenced bones should depend on the final bone.
        let tip = _fkChain[_fkChain.count - 1]
        for fk in _fkChain {
            if (fk === tip) {
                continue
            }
            
            let bone = fk.bone
            for node in bone.children! {
//                BoneChain item = _fkChain.firstWhere(
//                    (chainItem) => chainItem.bone == node,
//                    orElse: () => nil)
                if _fkChain.first(where: { $0.bone === node }) == nil {
                    _ = artboard!.addDependency(node, tip.bone)
                }
                // else {node is in the FK Chain}
            }
        }
    }
    
    func readIKConstraint(_ artboard: ActorArtboard, _ reader: StreamReader) {
//        ActorTargetedConstraint.read(artboard, reader, component)
        self.readTargetedConstraint(artboard, reader)
        self._invertDirection = reader.readBool(label: "isInverted")
        
        reader.openArray(label: "bones")
        let numInfluencedBones = Int(reader.readUint8Length())
        if numInfluencedBones > 0 {
            self._influencedBones = [InfluencedBone]()
            
            for i in 0 ..< numInfluencedBones {
                let idx = reader.readId(label: "") // No label here, we're just clearing the elements from the array.
                let ib = InfluencedBone(boneIndex: idx)
                self._influencedBones.insert(ib, at: i)
            }
        }
        reader.closeArray()
    }
    
    override func constrain(_ node: ActorNode) {
        guard let target = self.target as? ActorNode else {
            return
        }
        guard _influencedBones.count > 0 else {
            return
        }
        
        let worldTargetTranslation = Vec2D()
        _ = target.getWorldTranslation(vec: worldTargetTranslation)

        // Decompose the chain.
        for item in _fkChain {
            let bone = item.bone
            let parentWorld = bone.parent!.worldTransform
            _ = Mat2D.invert(item.parentWorldInverse, parentWorld)
            Mat2D.multiply(bone.transform, item.parentWorldInverse, bone.worldTransform)
            Mat2D.decompose(bone.transform, item.transformComponents)
        }
        
        let count = _boneData.count
        if count == 1 {
            solve1(_boneData[0], worldTargetTranslation)
        } else if (count == 2) {
            solve2(_boneData[0], _boneData[1], worldTargetTranslation)
        } else {
            let tip = _boneData[count - 1]
//            for (int i = 0 i < count - 1 i++) {
            for i in 0 ..< count {
                let item = _boneData[i]
                solve2(item, tip, worldTargetTranslation)
                for j in item.index+1 ..< _fkChain.count {
                    let fk = _fkChain[j]
                    _ = Mat2D.invert(fk.parentWorldInverse, fk.bone.parent!.worldTransform)
                }
            }
        }
        
        // At the end, mix the FK angle with the IK angle by strength
        if strength != 1.0 {
            for fk in _fkChain {
                if !fk.included {
                    let bone = fk.bone
                    Mat2D.multiply(bone.worldTransform, bone.parent!.worldTransform, bone.transform)
                    continue
                }
                let fromAngle = fk.transformComponents.rotation.remainder(dividingBy: ActorConstraint.PI2)
                let toAngle = Float(fk.angle).remainder(dividingBy: ActorConstraint.PI2)
                var diff = toAngle - fromAngle
                if (diff > Float.pi) {
                    diff -= ActorConstraint.PI2
                } else if (diff < -Float.pi) {
                    diff += ActorConstraint.PI2
                }
                let angle = fromAngle + diff * Float(strength)
                constrainRotation(fk, angle)
            }
        }
    }
    
    func constrainRotation(_ fk: BoneChain, _ rotation: Float) {
        let bone = fk.bone
        let parentWorld = bone.parent!.worldTransform
        let transform = bone.transform
        let c = fk.transformComponents
        
        if (rotation == 0.0) {
            Mat2D.identity(transform)
        } else {
            Mat2D.fromRotation(transform, rotation)
        }
        // Translate
        transform[4] = c.x
        transform[5] = c.y
        // Scale
        let scaleX = c.scaleX
        let scaleY = c.scaleY
        transform[0] *= scaleX
        transform[1] *= scaleX
        transform[2] *= scaleY
        transform[3] *= scaleY
        // Skew
        let skew = c.skew
        if (skew != 0.0) {
            transform[2] = transform[0] * skew + transform[2]
            transform[3] = transform[1] * skew + transform[3]
        }
        
        Mat2D.multiply(bone.worldTransform, parentWorld, transform)
    }
    
    func solve1(_ fk1: BoneChain, _ worldTargetTranslation: Vec2D) {
        let iworld = fk1.parentWorldInverse
        let pA = Vec2D()
        _ = fk1.bone.getWorldTranslation(vec: pA)
        let pBT = Vec2D(clone: worldTargetTranslation)
        
        // To target in worldspace
        let toTarget = Vec2D.subtract(Vec2D(), pBT, pA)
        // Note this is directional, hence not transformMat2d
        let toTargetLocal = Vec2D.transformMat2(Vec2D(), toTarget, iworld)
        let r = atan2(toTargetLocal[1], toTargetLocal[0])
        
        constrainRotation(fk1, r)
        fk1.angle = r
    }
    
    func solve2(_ fk1: BoneChain, _ fk2: BoneChain, _ worldTargetTranslation: Vec2D) {
        let b1 = fk1.bone
        let b2 = fk2.bone
        let firstChild = _fkChain[fk1.index + 1]
        
        let iworld = fk1.parentWorldInverse
        
        var pA = b1.getWorldTranslation(vec: Vec2D())
        var pC = firstChild.bone.getWorldTranslation(vec: Vec2D())
        var pB = b2.getTipWorldTranslation(Vec2D())
    
        var pBT = Vec2D(clone: worldTargetTranslation)
        
        pA = Vec2D.transformMat2D(pA, pA, iworld)
        pC = Vec2D.transformMat2D(pC, pC, iworld)
        pB = Vec2D.transformMat2D(pB, pB, iworld)
        pBT = Vec2D.transformMat2D(pBT, pBT, iworld)
        
        // http://mathworld.wolfram.com/LawofCosines.html
        let av = Vec2D.subtract(Vec2D(), pB, pC)
        let a = Vec2D.length(av)
        
        let bv = Vec2D.subtract(Vec2D(), pC, pA)
        let b = Vec2D.length(bv)
        
        let cv = Vec2D.subtract(Vec2D(), pBT, pA)
        let c = Vec2D.length(cv)
        
        let A = acos(max(-1, min(1, (-a * a + b * b + c * c) / (2 * b * c))))
        let C = acos(max(-1, min(1, (a * a + b * b - c * c) / (2 * a * b))))
        
        var r1: Float, r2: Float
        if (b2.parent != b1) {
            let secondChild = _fkChain[fk1.index + 2]
            
            let secondChildWorldInverse = secondChild.parentWorldInverse
            
            pC = firstChild.bone.getWorldTranslation(vec: Vec2D())
            pB = b2.getTipWorldTranslation(Vec2D())
            
            let avec = Vec2D.subtract(Vec2D(), pB, pC)
            let avLocal =
                Vec2D.transformMat2(Vec2D(), avec, secondChildWorldInverse)
            let angleCorrection = -atan2(avLocal[1], avLocal[0])
            
            if (_invertDirection) {
                r1 = atan2(cv[1], cv[0]) - A
                r2 = -C + Float.pi + angleCorrection
            } else {
                r1 = A + atan2(cv[1], cv[0])
                r2 = C - Float.pi + angleCorrection
            }
        } else if (_invertDirection) {
            r1 = atan2(cv[1], cv[0]) - A
            r2 = -C + Float.pi
        } else {
            r1 = A + atan2(cv[1], cv[0])
            r2 = C - Float.pi
        }
        
        constrainRotation(fk1, r1)
        constrainRotation(firstChild, r2)
        if (firstChild !== fk2) {
            let bone = fk2.bone
            Mat2D.multiply(bone.worldTransform, bone.parent!.worldTransform, bone.transform)
        }
        
        // Simple storage, need this for interpolation.
        fk1.angle = r1
        firstChild.angle = r2
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instance = ActorIKConstraint()
        instance.copyIKConstraint(self, resetArtboard)
        return instance
    }
    
    func copyIKConstraint(_ node: ActorIKConstraint, _ artboard: ActorArtboard) {
        self.copyTargetedConstraint(node, artboard)
        
        _invertDirection = node._invertDirection
        if (node._influencedBones != nil) {
            _influencedBones = [InfluencedBone]()
            let c = node._influencedBones.count
            for i in 0 ..< c {
                let bIdx = node._influencedBones[i].boneIdx
                let ib = InfluencedBone(boneIndex: bIdx)
                _influencedBones.insert(ib, at: i)
            }
        }
    }
    
    override func update(dirt: UInt8) {}
}
