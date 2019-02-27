//
//  actor_constraint.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/13/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

/*abstract*/
class ActorConstraint: ActorComponent {
    
    override init() {
        super.init()
        assert(type(of: self) != ActorConstraint.self, "Abstract Class")
    }
    var _isEnabled : Bool = false
    var _strength: Double = 0.0
    
    var isEnabled: Bool {
        get {
            return _isEnabled
        }
        set {
            if newValue != _isEnabled {
                _isEnabled = newValue
                markDirty()
            }
        }
    }
    
    var strength: Double {
        get {
            return _strength
        }
        set {
            if newValue != _strength {
                _strength = newValue
                markDirty()
            }
        }
    }
    
    override func onDirty(_ dirt: UInt8) {
        markDirty()
    }
    
    func markDirty() {
        parent!.markTransformDirty()
    }
    
    func constrain(_ node: ActorNode) {
        preconditionFailure("This method must be overridden")
    }
    
    func resolveComponentIndices(_ components: [ActorComponent]) {
        super.resolveComponentIndices(components)
        if let p = parent {
            // This works because nodes are exported in hierarchy order, so we are assured constraints get added in order as we resolve indices.
            _ = p.addConstraint(self)
        }
    }
    
    func readConstraint(_ artboard: ActorArtboard, _ reader: StreamReader) {
//        _ = ActorComponent.read(artboard, reader, component)
        self.readComponent(artboard, reader)
        self._strength = Double(reader.readFloat32(label: "strength"))
        self._isEnabled = reader.readBool(label: "isEnabled")
    }
    
    func copyConstraint(_ node: ActorConstraint, _ resetArtboard: ActorArtboard) {
        copyComponent(node, resetArtboard)
        _isEnabled = node._isEnabled
        _strength = node._strength
    }
}
