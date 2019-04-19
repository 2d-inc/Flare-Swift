//
//  jelly_component.swift
//  FlareCore
//
//  Created by Umberto Sonnino on 3/6/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class JellyComponent: ActorComponent {
    static let JellyMax: Int = 16
    static let OptimalDistance: Float = 4.0 * (sqrt(2.0) - 1.0) / 3.0
    static let CurveConstant: Float = OptimalDistance * sqrt(2.0) * 0.5
    static let Epsilon: Float = 0.001 // Intentionally agressive.
    
    var _easeIn: Float = -1
    var _easeOut: Float = -1
    var _scaleIn: Float = -1
    var _scaleOut: Float = -1
    var _inTargetIdx: Int = -1
    var _outTargetIdx: Int = -1
    var _inTarget: ActorNode?
    var _outTarget: ActorNode?
    var _bones: [ActorJellyBone]?
    var _inPoint: Vec2D
    var _inDirection: Vec2D
    var _outPoint: Vec2D
    var _outDirection: Vec2D
    
    var _cachedTip: Vec2D
    var _cachedOut: Vec2D
    var _cachedIn: Vec2D
    var _cachedScaleIn: Float = -1
    var _cachedScaleOut: Float = -1
    
    var _jellyPoints: [Vec2D]
    
    var inTarget: ActorNode? {
        return _inTarget
    }
    var outTarget: ActorNode? {
        return _outTarget
    }
    
    override init() {
        _inPoint = Vec2D()
        _inDirection = Vec2D()
        _outPoint = Vec2D()
        _outDirection = Vec2D()
        _cachedTip = Vec2D()
        _cachedOut = Vec2D()
        _cachedIn = Vec2D()
        _jellyPoints = [Vec2D](repeating: Vec2D(), count: JellyComponent.JellyMax+1)
    }
    
    static func fuzzyEquals(_ a: Vec2D, _ b: Vec2D) -> Bool {
        let a0 = a[0], a1 = a[1]
        let b0 = b[0], b1 = b[1]
        return (abs(a0 - b0) <= Epsilon * max(1.0, max(abs(a0), abs(b0))) &&
            abs(a1 - b1) <= Epsilon * max(1.0, max(abs(a1), abs(b1))))
    }
    
    static func forwardDiffBezier(c0: inout Float, c1: inout Float, c2: inout Float, c3: inout Float, points: [Vec2D], count: Int, offset: Int) {
        let fCount = Float(count)
        var f = Float(count)
        
        let p0 = c0
        
        let p1 = 3.0 * (c1 - c0) / f
        
        f *= fCount
        let p2 = 3.0 * (c0 - 2.0 * c1 + c2) / f
        
        f *= fCount
        let p3 = (c3 - c0 + 3.0 * (c1 - c2)) / f
        
        c0 = p0
        c1 = p1 + p2 + p3
        c2 = 2 * p2 + 6 * p3
        c3 = 6 * p3
        
        for a in 0...count {
            points[a][offset] = c0
            c0 += c1
            c1 += c2
            c2 += c3
        }
    }
    
    func normalizeCurve(curve: inout [Vec2D], numSegments: Int) -> [Vec2D] {
        var points = [Vec2D]()
        let curvePointCount = curve.count
        var distances = [Float](repeating: 0.0, count: curvePointCount)
        distances[0] = 0.0
        
        for i in 0 ..< curvePointCount - 1 {
            let p1 = curve[i]
            let p2 = curve[i + 1]
            distances[i + 1] = distances[i] + Vec2D.distance(p1, p2)
        }
        let totalDistance = distances[curvePointCount - 1]
        
        let segmentLength = totalDistance / Float(numSegments)
        var pointIndex = 1
        for i in 1 ... numSegments {
            let distance = segmentLength * Float(i)
            
            while (pointIndex < curvePointCount - 1 &&
                distances[pointIndex] < distance) {
                    pointIndex += 1
            }
            
            let d = distances[pointIndex]
            let lastCurveSegmentLength = d - distances[pointIndex - 1]
            let remainderOfDesired = d - distance
            let ratio = remainderOfDesired / lastCurveSegmentLength
            let iratio = 1.0 - ratio
            
            let p1 = curve[pointIndex - 1]
            let p2 = curve[pointIndex]
            points.append(Vec2D(fromValues: p1[0] * ratio + p2[0] * iratio, p1[1] * ratio + p2[1] * iratio))
        }
        
        return points
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instance = JellyComponent()
        instance.copyJelly(self, resetArtboard)
        return instance
    }
    
    func copyJelly(_ component: JellyComponent, _ artboard: ActorArtboard) {
        self.copyComponent(component, artboard)
        _easeIn = component._easeIn
        _easeOut = component._easeOut
        _scaleIn = component._scaleIn
        _scaleOut = component._scaleOut
        _inTargetIdx = component._inTargetIdx
        _outTargetIdx = component._outTargetIdx
    }
    
    func resolveComponentIndices(components: [ActorComponent]) {
        guard let aboard = self.artboard else {
            fatalError("JellyComponent@resolveComponentIndices() - No Artboard??")
        }
        super.resolveComponentIndices(components)
        
        if (_inTargetIdx != 0) {
            _inTarget = (components[_inTargetIdx] as! ActorNode)
        }
        if (_outTargetIdx != 0) {
            _outTarget = (components[_outTargetIdx] as! ActorNode)
        }
        
        var dependencyConstraints = [ActorConstraint]()
        if let bone = parent as? ActorBone {
            _ = artboard!.addDependency(self, bone)
            dependencyConstraints += bone.allConstraints!
            if let firstBone = bone.firstBone {
                _ = aboard.addDependency(self, firstBone)
                dependencyConstraints += firstBone.allConstraints!
                
                // If we don't have an out target and the child jelly does have an in target
                // we are dependent on that target's position.
                if _outTarget == nil && firstBone.jelly != nil && firstBone.jelly?.inTarget != nil {
                    let inTarget = firstBone.jelly!.inTarget!
                    _ = aboard.addDependency(self, inTarget)
                    dependencyConstraints += inTarget.allConstraints!
                }
            }
            if let parentBone = bone.parent as? ActorBone {
                if let parentBoneJelly = parentBone.jelly, let outTarget = parentBoneJelly.outTarget {
                    _ = aboard.addDependency(self, outTarget)
                    dependencyConstraints += outTarget.allConstraints!
                }
            }
        }
        
        if let inTarget = _inTarget {
            _ = aboard.addDependency(self, inTarget)
            dependencyConstraints += inTarget.allConstraints!
        }
        if let outTarget = _outTarget {
            _ = aboard.addDependency(self, outTarget)
            dependencyConstraints += outTarget.allConstraints!
        }
        
        // We want to depend on any and all constraints that our dependents have.
        let constraints = Set(dependencyConstraints.map{ $0 })
        for constraint in constraints {
            _ = aboard.addDependency(self, constraint)
        }
    }
    
    override func completeResolve() {
        let bone = parent as! ActorBone
        bone.jelly = self
        
        // Get jellies.
        guard let children = bone.children else {
            return
        }
        
        _bones = [ActorJellyBone]()
        for child in children {
            if let jelly = child as? ActorJellyBone {
                _bones!.append(jelly)
                // Make sure the jelly doesn't update until the jelly component has updated
                _ = artboard!.addDependency(jelly, self)
            }
        }
    }
    
    func readJellyComponent(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readComponent(artboard, reader)
        
        self._easeIn = reader.readFloat32(label: "easeIn")
        self._easeOut = reader.readFloat32(label: "easeOut")
        self._scaleIn = reader.readFloat32(label: "scaleIn")
        self._scaleOut = reader.readFloat32(label: "scaleOut")
        self._inTargetIdx = reader.readId(label: "inTargetId")
        self._outTargetIdx = reader.readId(label: "outTargetId")
    }
    
    func updateJellies() {
        guard let bones = _bones else {
            return
        }
        let bone = parent as! ActorBone
        // We are in local bone space.
        let tipPosition = Vec2D(fromValues: bone.length, 0.0)
        
        if (JellyComponent.fuzzyEquals(_cachedTip, tipPosition) &&
            JellyComponent.fuzzyEquals(_cachedOut, _outPoint) &&
            JellyComponent.fuzzyEquals(_cachedIn, _inPoint) &&
            _cachedScaleIn == _scaleIn &&
            _cachedScaleOut == _scaleOut) {
            return
        }
        
        Vec2D.copy(_cachedTip, tipPosition)
        Vec2D.copy(_cachedOut, _outPoint)
        Vec2D.copy(_cachedIn, _inPoint)
        _cachedScaleIn = _scaleIn
        _cachedScaleOut = _scaleOut
        
        let q0 = Vec2D()
        let q1 = _inPoint
        let q2 = _outPoint
        let q3 = tipPosition
        
        JellyComponent.forwardDiffBezier(c0: &q0[0], c1: &q1[0], c2: &q2[0], c3: &q3[0], points: _jellyPoints, count: JellyComponent.JellyMax, offset: 0)
        JellyComponent.forwardDiffBezier(c0: &q0[1], c1: &q1[1], c2: &q2[1], c3: &q3[1], points: _jellyPoints, count: JellyComponent.JellyMax, offset: 1)
        
        let normalizedPoints = normalizeCurve(curve: &_jellyPoints, numSegments: bones.count)
        
        var lastPoint = _jellyPoints[0]
        
        let scaleInc = (_scaleOut - _scaleIn) / Float(bones.count - 1)
        var scale = _scaleIn
//        for (int i = 0 i < normalizedPoints.length i++) {
        for i in 0 ..< normalizedPoints.count {
            let jelly = bones[i]
            let p = normalizedPoints[i]
            
            jelly.translation = lastPoint
            jelly.length = Vec2D.distance(p, lastPoint)
            jelly.scaleY = scale
            scale += scaleInc
            
            let diff = Vec2D.subtract(Vec2D(), p, lastPoint)
            jelly.rotation = Double(atan2(diff[1], diff[0]))
            lastPoint = p
        }
    }
    
    override func onDirty(_ dirt: UInt8) {
        // Intentionally empty. Doesn't throw dirt around.
    }
    
    override func update(dirt: UInt8) {
        guard let bone = parent as? ActorBone else {
            fatalError("JellyComponent@update() - bone is nil!")
        }
        
        let parentBone = bone.parent
        var parentBoneJelly: JellyComponent?
        if let pb = parentBone as? ActorBone {
            parentBoneJelly = pb.jelly
        }
        
        let inverseWorld = Mat2D()
        if (!Mat2D.invert(inverseWorld, bone.worldTransform)) {
            return
        }
        
        if let inTarget = _inTarget {
            let translation = inTarget.getWorldTranslation(vec: Vec2D())
            _ = Vec2D.transformMat2D(_inPoint, translation, inverseWorld)
            Vec2D.normalize(_inDirection, _inPoint)
        } else if (parentBone != nil) {
            var firstBone: ActorBone?
            if let pb = parentBone as? ActorBone {
                firstBone = pb.firstBone
            } else if let pb = parentBone as? ActorRootBone {
                firstBone = pb.firstBone
            }
            
            if (firstBone === bone && parentBoneJelly != nil && parentBoneJelly!._outTarget != nil) {
                let pbj = parentBoneJelly!
                let outT = pbj._outTarget!
                let translation = outT.getWorldTranslation(vec: Vec2D())
                let localParentOut = Vec2D.transformMat2D(Vec2D(), translation, inverseWorld)
                Vec2D.normalize(localParentOut, localParentOut)
                _ = Vec2D.negate(_inDirection, localParentOut)
            } else {
                let d1 = Vec2D.init(fromValues: 1.0, 0.0)
                let d2 = Vec2D.init(fromValues: 1.0, 0.0)
                
                _ = Vec2D.transformMat2(d1, d1, parentBone!.worldTransform)
                _ = Vec2D.transformMat2(d2, d2, bone.worldTransform)
                
                let sum = Vec2D.add(Vec2D(), d1, d2)
                _ = Vec2D.transformMat2(_inDirection, sum, inverseWorld)
                Vec2D.normalize(_inDirection, _inDirection)
            }
            _inPoint[0] = _inDirection[0] * _easeIn * bone.length * JellyComponent.CurveConstant
            _inPoint[1] = _inDirection[1] * _easeIn * bone.length * JellyComponent.CurveConstant
        } else {
            _inDirection[0] = 1.0
            _inDirection[1] = 0.0
            _inPoint[0] = _inDirection[0] * _easeIn * bone.length * JellyComponent.CurveConstant
        }
        
        if let outT = _outTarget {
            let translation = outT.getWorldTranslation(vec: Vec2D())
            _ = Vec2D.transformMat2D(_outPoint, translation, inverseWorld)
            let tip = Vec2D.init(fromValues: bone.length, 0.0)
            _ = Vec2D.subtract(_outDirection, _outPoint, tip)
            Vec2D.normalize(_outDirection, _outDirection)
        } else if (bone.firstBone != nil) {
            let firstBone = bone.firstBone!
            let firstBoneJelly = firstBone.jelly
            if (firstBoneJelly != nil && firstBoneJelly!._inTarget != nil) {
                let inT = firstBoneJelly!._inTarget!
                let translation = inT.getWorldTranslation(vec: Vec2D())
                let worldChildInDir = Vec2D.subtract(Vec2D(), firstBone.getWorldTranslation(vec: Vec2D()), translation)
                _ = Vec2D.transformMat2(_outDirection, worldChildInDir, inverseWorld)
            } else {
                let d1 = Vec2D.init(fromValues: 1.0, 0.0)
                let d2 = Vec2D.init(fromValues: 1.0, 0.0)
                
                _ = Vec2D.transformMat2(d1, d1, firstBone.worldTransform)
                _ = Vec2D.transformMat2(d2, d2, bone.worldTransform)
                
                let sum = Vec2D.add(Vec2D(), d1, d2)
                let negativeSum = Vec2D.negate(Vec2D(), sum)
                _ = Vec2D.transformMat2(_outDirection, negativeSum, inverseWorld)
                Vec2D.normalize(_outDirection, _outDirection)
            }
            Vec2D.normalize(_outDirection, _outDirection)
            let scaledOut = Vec2D.scale(
                Vec2D(), _outDirection, _easeOut * bone.length * JellyComponent.CurveConstant)
            _outPoint[0] = bone.length
            _outPoint[1] = 0.0
            _ = Vec2D.add(_outPoint, _outPoint, scaledOut)
        } else {
            _outDirection[0] = -1.0
            _outDirection[1] = 0.0
            
            let scaledOut = Vec2D.scale(
                Vec2D(), _outDirection, _easeOut * bone.length * JellyComponent.CurveConstant)
            _outPoint[0] = bone.length
            _outPoint[1] = 0.0
            _ = Vec2D.add(_outPoint, _outPoint, scaledOut)
        }
        
        updateJellies()
    }
}
