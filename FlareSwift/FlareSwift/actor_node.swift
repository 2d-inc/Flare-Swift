//
//  actor_node.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/13/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public class ActorClip {
    var clipIdx: Int
    var node: ActorNode?
    
    public init(_ idx: Int) {
        self.clipIdx = idx
    }
}

public class ActorNode: ActorComponent {
    let TransformDirty = DirtyFlags.TransformDirty
    let WorldTransformDirty = DirtyFlags.WorldTransformDirty
    
    var _children : [ActorNode]?
    var _transform = Mat2D()
    var _worldTransform = Mat2D()
    var _translation = Vec2D()
    var _scale: Vec2D = Vec2D(fromValues: 1.0, 1.0)
    var _rotation = 0.0
    var _opacity = 1.0
    var _renderOpacity = 1.0
    
    var _overrideWorldTransform = false
    var _isCollapsedVisibility = false
    
    var _renderCollapsed = false
    var _clips : [ActorClip]?

    var _constraints: [ActorConstraint]?
    var _peerConstraints: [ActorConstraint]?
    
    public var transform: Mat2D {
        get {
            return self._transform
        }
    }
    
    var clips: [ActorClip]? {
        get {
            return self._clips
        }
    }
    
    var worldTransformOverride: Mat2D? {
        get {
            return self._overrideWorldTransform ? _worldTransform : nil
        }
        set {
            if newValue == nil {
                _overrideWorldTransform = false
            } else {
                _overrideWorldTransform = true
                Mat2D.copy(self._worldTransform, newValue!)
            }
        }
    }
    
    var worldTransform: Mat2D {
        get {
            return self._worldTransform
        }
        set {
            Mat2D.copy(self._worldTransform, newValue)
        }
    }
    
    var x: Float32 {
        get {
            return _translation[0]
        }
        set {
            if _translation[0] != newValue {
                _translation[0] = newValue
                markTransformDirty()
            }
        }
    }
    
    var y: Float32 {
        get {
            return _translation[1]
        }
        set {
            if _translation[1] != newValue {
                _translation[1] = newValue
                markTransformDirty()
            }
        }
    }
    
    var translation: Vec2D {
        get {
            return Vec2D(clone: self._translation)
        }
        set {
            Vec2D.copy(self._translation, newValue)
            markTransformDirty()
        }
    }
    
    var rotation: Double {
        get {
            return self._rotation
        }
        set {
            if rotation != newValue {
                self._rotation = newValue
                markTransformDirty()
            }
        }
    }
    
    var scaleX: Float32 {
        get {
            return self._scale[0]
        }
        set {
            if self._scale[0] != newValue {
                self._scale[0] = newValue
                markTransformDirty()
            }
        }
    }
    
    var scaleY: Float32 {
        get {
            return self._scale[1]
        }
        set {
            if self._scale[1] != newValue {
                self._scale[1] = newValue
                markTransformDirty()
            }
        }
    }
    
    var opacity: Double {
        get {
            return self._opacity
        }
        set {
            if self._opacity != newValue {
                self._opacity = newValue
                markTransformDirty()
            }
        }
    }
    
    var renderOpacity: Double {
        get {
            return self._renderOpacity
        }
    }
    
    public var renderCollapsed: Bool {
        get {
            return self._renderCollapsed
        }
    }
    
    var collapsedVisibility: Bool {
        get {
            return self._isCollapsedVisibility
        }
        set {
            if self._isCollapsedVisibility != newValue {
                self._isCollapsedVisibility = newValue
                markTransformDirty()
            }
        }
    }
    
    public var allClips: [[ActorClip]] {
        get {
            var all = [[ActorClip]]()
            var clipSearch: ActorNode? = self
            
            while let cs = clipSearch {
                if let c = cs.clips {
                    all.append(c)
                }
                clipSearch = cs.parent
            }
            
            return all
        }
    }
    
    var children: [ActorNode]? {
        get {
            return _children
        }
    }
    
    func markTransformDirty() {
        if artboard == nil {
            // Still loading?
            return
        }
        if !artboard!.addDirt(self, value: self.TransformDirty, recurse: false) {
            return
        }
        _ = artboard!.addDirt(self, value: self.WorldTransformDirty, recurse: true)
    }
    
    func updateTransform() {
        Mat2D.fromRotation(_transform, Float32(_rotation))
        _transform[4] = _translation[0]
        _transform[5] = _translation[1]
        Mat2D.scale(_transform, _transform, _scale)
    }
    
    func getWorldTranslation(vec: Vec2D) -> Vec2D {
        vec[0] = _worldTransform[4]
        vec[1] = _worldTransform[5]
        return vec
    }
    
    func updateWorldTransform() {
        _renderOpacity = _opacity
        
        if let p = parent {
            _renderCollapsed = _isCollapsedVisibility || p._renderCollapsed
            _renderOpacity *= p._renderOpacity
            if (!_overrideWorldTransform) {
                Mat2D.multiply(_worldTransform, p._worldTransform, _transform)
            }
        } else {
            Mat2D.copy(_worldTransform, _transform)
        }
    }
    
    public func readNode(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readComponent(artboard, reader)
        reader.readFloat32ArrayOffset(ar: &self._translation.values, length: 2, offset: 0, label: "translation")
        self._rotation = Double(reader.readFloat32(label: "rotation"))
        reader.readFloat32ArrayOffset(ar: &self._scale.values, length: 2, offset: 0, label: "scale")
        self._opacity = Double(reader.readFloat32(label: "opacity"))
        self._isCollapsedVisibility = reader.readBool(label: "isCollapsed")
        
        reader.openArray(label: "clips")
        let clipCount: Int = Int(reader.readUint8Length())
        if clipCount > 0 {
            self._clips = Array<ActorClip>()
            for i in 0 ..< clipCount {
                self._clips!.insert(ActorClip(reader.readId(label: "clip")), at: i)
            }
        }
        reader.closeArray()
    }
    
    func addChild(_ node: ActorNode) {
        if let p = node.parent {
            if let idx = p._children?.firstIndex(of: node) {
                p._children?.remove(at: idx)
            }
        }
        
        node.parent = self
        if _children == nil {
            _children = Array<ActorNode>()
        }
        _children!.append(node)
    }
    
    public func copyNode(_ node: ActorNode, _ resetArtboard: ActorArtboard) {
        copyComponent(node, resetArtboard)
        _transform = Mat2D(clone: node._transform)
        _worldTransform = Mat2D(clone: node._worldTransform)
        _translation = Vec2D(clone: node._translation)
        _scale = Vec2D(clone: node._scale)
        _rotation = node._rotation
        _opacity = node._opacity
        _renderOpacity = node._renderOpacity
        _overrideWorldTransform = node._overrideWorldTransform
        
        if let nodeClips = node._clips {
            _clips = Array<ActorClip>()
            for (index, value) in nodeClips.enumerated() {
                _clips!.insert(ActorClip(value.clipIdx), at: index)
            }
        } else {
            _clips = nil
        }
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceNode = ActorNode()
        instanceNode.copyNode(self, resetArtboard)
        return instanceNode
    }
    
    override func onDirty(_ dirt: UInt8) {}
    
    func addConstraint(_ constraint: ActorConstraint) -> Bool {
        if _constraints == nil {
            _constraints = Array<ActorConstraint>()
        }
        if _constraints!.contains(constraint) {
            return false
        }
        _constraints!.append(constraint)
        return true
    }
    
    func addPeerConstraint(constraint: ActorConstraint) -> Bool {
        if (_peerConstraints == nil) {
            _peerConstraints = Array<ActorConstraint>()
        }
        if (_peerConstraints!.contains(constraint)) {
            return false
        }
        _peerConstraints!.append(constraint)
        return true
    }
    
    var allConstraints: [ActorConstraint]? {
        get {
            return _constraints == nil ? _peerConstraints :
                _peerConstraints == nil ? _constraints :
                 _constraints == nil && _peerConstraints == nil ? [] : _constraints! + _peerConstraints!
        }
    }
    
    override func update(dirt: UInt8) {
        if (dirt & TransformDirty) == TransformDirty {
            updateTransform()
        }
        if (dirt & WorldTransformDirty) == WorldTransformDirty {
            updateWorldTransform()
            if let c = _constraints {
                for constraint in c {
                    if constraint.isEnabled {
                        constraint.constrain(self)
                    }
                }
            }
        }
    }
    
    override func resolveComponentIndices(_ components: [ActorComponent?]) {
        super.resolveComponentIndices(components)
    
        if let clips = _clips {
            for clip in clips {
                clip.node = components[clip.clipIdx] as? ActorNode
            }
        }
    }
    
    override func completeResolve() {
        // Nothing to complete for actornode.
    }
    
    func eachChildRecursive(_ cb: ((ActorNode)->Bool)) -> Bool {
        guard let children = _children else {
            return true
        }
        
        for child in children {
            if (cb(child) == false) {
                return false
            }
            if (child.eachChildRecursive(cb) == false) {
                return false
            }
        }
        return true
    }
    
    func all(_ cb: (ActorNode)->Bool) -> Bool {
        if cb(self) == false {
            return false
        }
        
        guard let children = _children else {
            return true
        }
        
        for child in children {
            if cb(child) == false {
                return false
            }
            let _ = child.eachChildRecursive(cb)
        }

        return true
    }
    
    func invalidateShape() {}
}
