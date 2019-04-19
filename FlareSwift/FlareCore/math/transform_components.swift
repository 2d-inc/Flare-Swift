//
//  transform_components.swift
//  FlareCore
//
//  Created by Umberto Sonnino on 2/12/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class TransformComponents {
    var _buffer : [Float32]
    
    var values : [Float32] {
        get {
            return self._buffer
        }
    }
    
    // Overload [] operator for this class
    subscript(index: Int) -> Float32 {
        get {
            return _buffer[index]
        }
        set {
            _buffer[index] = newValue
        }
    }
    
    init() {
        self._buffer = [1.0, 0.0, 0.0, 1.0, 0.0, 0.0]
    }
    
    init(clone copy: TransformComponents) {
        _buffer = copy.values
    }
    
    var x : Float32 {
        get {
            return self._buffer[0]
        }
        set {
            self._buffer[0] = newValue
        }
    }
    
    var y : Float32 {
        get {
            return self._buffer[1]
        }
        set {
            self._buffer[1] = newValue
        }
    }
    
    var scaleX : Float32 {
        get {
            return self._buffer[2]
        }
        set {
            self._buffer[2] = newValue
        }
    }
    
    var scaleY : Float32 {
        get {
            return self._buffer[3]
        }
        set {
            self._buffer[3] = newValue
        }
    }
    
    var rotation : Float32 {
        get {
            return self._buffer[4]
        }
        set {
            self._buffer[4] = newValue
        }
    }
    
    var skew : Float32 {
        get {
            return self._buffer[5]
        }
        set {
            self._buffer[5] = newValue
        }
    }
    
    var translation : Vec2D {
        get {
            return Vec2D(fromValues: self._buffer[0], self._buffer[1])
        }
    }
    
    var scale : Vec2D {
        get {
            return Vec2D(fromValues: self._buffer[2], self._buffer[3])
        }
    }
}
