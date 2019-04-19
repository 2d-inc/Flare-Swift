//
//  actor_targeted_constraint.swift
//  FlareCore
//
//  Created by Umberto Sonnino on 2/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

/* Abstract */
class ActorTargetedConstraint: ActorConstraint {
    
    override init() {
        super.init()
        assert(type(of: self) != ActorConstraint.self, "Abstract Class")
    }
    
    var _targetIdx = 0
    var _target: ActorComponent?
    
    var target: ActorComponent? {
        return _target
    }
    
    override func resolveComponentIndices(_ components: [ActorComponent?]) {
        super.resolveComponentIndices(components);
        if _targetIdx != 0 {
            _target = components[_targetIdx]
            if _target != nil {
                _ = artboard!.addDependency(parent!, _target!)
            }
        }
    }
    
    func readTargetedConstraint(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readConstraint(artboard, reader)
        self._targetIdx = reader.readId(label: "target")
    }
    
    func copyTargetedConstraint(_ node: ActorTargetedConstraint, _ resetArtboard: ActorArtboard) {
        copyConstraint(node, resetArtboard);
        _targetIdx = node._targetIdx;
    }
}
