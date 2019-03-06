//
//  actor_distance_constraint.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

enum DistanceMode: Int {
    case Closer = 0, Further, Exact
}

class ActorDistanceConstraint: ActorTargetedConstraint {
    var _distance: Float32 = 100.0
    var _mode = DistanceMode.Closer
    
    var distance: Float32 {
        get {
            return _distance
        }
        set {
            if newValue != _distance {
                _distance = newValue
                self.markDirty()
            }
        }
    }
    
    var mode: DistanceMode {
        get {
            return _mode
        }
        set {
            if newValue != _mode {
                _mode = newValue
                self.markDirty()
            }
        }
    }
    
    override init() {}
    
    func readDistanceConstraint(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readTargetedConstraint(artboard, reader)
        
        self._distance = reader.readFloat32(label: "distance")
        self._mode = DistanceMode(rawValue: Int(reader.readUint8(label: "modeId")))!
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorDistanceConstraint {
        let node = ActorDistanceConstraint()
        node.copyDistanceConstraint(self, resetArtboard)
        return node
    }
    
    func copyDistanceConstraint(_ node: ActorDistanceConstraint, _ resetArtboard: ActorArtboard) {
        copyTargetedConstraint(node, resetArtboard);
        _distance = node._distance;
        _mode = node._mode;
    }
    
    override func constrain(_ node: ActorNode) {
        guard let t = (self._target as? ActorNode) else {
            return
        }
        
        let p = self.parent;
        let targetTranslation = t.getWorldTranslation(vec: Vec2D());
        let ourTranslation = p!.getWorldTranslation(vec: Vec2D());
        
        let toTarget = Vec2D.subtract(Vec2D(), ourTranslation, targetTranslation);
        let currentDistance = Vec2D.length(toTarget)
        switch (_mode) {
        case DistanceMode.Closer:
            if (currentDistance < _distance) {
                return
            }
            break;
            
        case DistanceMode.Further:
            if (currentDistance > _distance) {
                return
            }
            break
        case .Exact:
            break
        }
        
        if (currentDistance < 0.001) {
            return;
        }
        
        _ = Vec2D.scale(toTarget, toTarget, 1.0 / currentDistance);
        _ = Vec2D.scale(toTarget, toTarget, _distance);
        
        let world = p!.worldTransform;
        let position = Vec2D.lerp(Vec2D(), ourTranslation, Vec2D.add(Vec2D(), targetTranslation, toTarget), Float32(strength))
        world[4] = position[0];
        world[5] = position[1];
    }
    
    override func update(dirt: UInt8) {}
    override func completeResolve() {
        super.completeResolve()
    }
}

