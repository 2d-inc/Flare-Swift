//
//  actor_axis_constraint.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

/*abstract*/ class ActorAxisConstraint: ActorTargetedConstraint {
    var _copyX = false
    var _copyY = false
    var _enableMinX = false
    var _enableMaxX = false
    var _enableMinY = false
    var _enableMaxY = false
    var _offset = false
    
    var _scaleX = 1.0
    var _scaleY = 1.0
    var _minX = 0.0
    var _maxX = 0.0
    var _minY = 0.0
    var _maxY = 0.0
    
    var _sourceSpace = TransformSpace.World
    var _destSpace = TransformSpace.World
    var _minMaxSpace = TransformSpace.World
    
    var copyX: Bool {
        return _copyX
    }
    var copyY: Bool {
        return _copyY
    }
    var destSpace: TransformSpace {
        return _destSpace
    }
    var enableMaxX: Bool {
        return _enableMaxX
    }
    var enableMaxY: Bool {
        return _enableMaxY
    }
    var enableMinX: Bool {
        return _enableMinX
    }
    var enableMinY: Bool {
        return _enableMinY
    }
    var maxX: Double {
        return _maxX
    }
    var maxY: Double {
        return _maxY
    }
    var minMaxSpace: TransformSpace {
        return _minMaxSpace
    }
    var minX: Double {
        return _minX
    }
    var minY: Double {
        return _minY
    }
    var offset: Bool {
        return _offset
    }
    var scaleX: Double {
        return _scaleX
    }
    var scaleY: Double {
        return _scaleY
    }
    var sourceSpace: TransformSpace {
        return _sourceSpace
    }
    
    override init() {}
    
    func readAxisConstraint(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readTargetedConstraint(artboard, reader)
        self._copyX = reader.readBool(label: "copyX")
        if self._copyX {
            self._scaleX = Double(reader.readFloat32(label: "scaleX"))
        }
        
        self._enableMinX = reader.readBool(label: "enableMinX")
        if self._enableMinX {
            self._minX = Double(reader.readFloat32(label: "minX"))
        }
        
        self._enableMaxX = reader.readBool(label: "enableMaxX")
        if self._enableMaxX {
            self._maxX = Double(reader.readFloat32(label: "maxX"))
        }
        
        self._copyY = reader.readBool(label: "copyY")
        if self._copyY {
            self._scaleY = Double(reader.readFloat32(label: "scaleY"))
        }
        
        self._enableMinY = reader.readBool(label: "enableMinY")
        if self._enableMinY {
            self._minY = Double(reader.readFloat32(label: "minY"))
        }
        
        self._enableMaxY = reader.readBool(label: "enableMaxY")
        if self._enableMaxY {
            self._maxY = Double(reader.readFloat32(label: "maxY"))
        }
        
        self._offset = reader.readBool(label: "offset")
        self._sourceSpace = TransformSpace(rawValue: Int(reader.readUint8(label: "sourceSpaceId")))!
        self._destSpace = TransformSpace(rawValue: Int(reader.readUint8(label: "destSpaceId")))!
        self._minMaxSpace = TransformSpace(rawValue: Int(reader.readUint8(label: "minMaxSpaceId")))!
    }
    
    func copyAxisConstraint(_ node: ActorAxisConstraint, _ resetArtboard: ActorArtboard) {
        self.copyTargetedConstraint(node, resetArtboard);
        
        _copyX = node._copyX;
        _copyY = node._copyY;
        _enableMinX = node._enableMinX;
        _enableMaxX = node._enableMaxX;
        _enableMinY = node._enableMinY;
        _enableMaxY = node._enableMaxY;
        _offset = node._offset;
        
        _scaleX = node._scaleX;
        _scaleY = node._scaleY;
        _minX = node._minX;
        _maxX = node._maxX;
        _minY = node._minY;
        _maxY = node._maxY;
        
        _sourceSpace = node._sourceSpace;
        _destSpace = node._destSpace;
        _minMaxSpace = node._minMaxSpace;
    }
    
    override func onDirty(_ dirt: UInt8) {
        markDirty()
    }
}
