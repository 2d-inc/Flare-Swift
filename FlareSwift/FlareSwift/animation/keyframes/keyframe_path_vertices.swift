//
//  keyframe_path_vertices.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class KeyFramePathVertices: Interpolated {
    private var _vertices: [Float32]
    private var _component: ActorComponent
    var vertices: [Float32] {
        return _vertices
    }
    var _interpolator: Interpolator?
    var _time: Double = 0.0
    
    init(component: ActorComponent) {
        assert(component is ActorPath, "KeyFramePathVertices::init() - Component was NOT an ActorPath!")
        self._component = component
        _vertices = []
    }
    
    func applyInterpolation(component: ActorComponent, time: Double, toFrame: KeyFrame, mix: Double) {
        let path = _component as! ActorPath
//        let wr = path.vertexDeform;
        let to = (toFrame as! KeyFramePathVertices)
        let l = _vertices.count
        
        let fMix = Float32(mix)
        let f: Float32 = Float32((time - _time) / (toFrame._time - _time))
        let fi = 1.0 - f
        if (mix == 1.0) {
//            for (int i = 0; i < l; i++) {
            for i in 0 ..< l {
                path.vertexDeform![i] = _vertices[i] * fi + to._vertices[i] * f
            }
        } else {
            let mixi = 1.0 - fMix;
//            for (int i = 0; i < l; i++) {
            for i in 0 ..< l {
                let v = _vertices[i] * fi + to._vertices[i] * f;
                
                path.vertexDeform![i] = path.vertexDeform![i] * mixi + v * fMix
            }
        }
        
        path.markVertexDeformDirty();
    }
    
    func apply(component: ActorComponent, mix: Double) {
        let path = _component as! ActorPath
        let l = _vertices.count
        let fMix: Float32 = Float32(mix)
        
        if fMix == 1.0 {
            for i in 0 ..< l {
                path.vertexDeform![i] = _vertices[i]
            }
        } else {
            let mixi = 1.0 - fMix
            for i in 0 ..< l {
                path.vertexDeform![i] = path.vertexDeform![i] * mixi + _vertices[i] * fMix
            }
        }
        
        path.markVertexDeformDirty();
    }
    
    func setNext(_ frame: KeyFrame) {
        // Do nothing.
    }
    
    func read(_ reader: StreamReader) -> Bool {
        if !self.readInterpolation(reader) {
            return false
        }
        
        let pathNode = _component as! ActorPath
        
        var length = 0
        for point in pathNode.points {
            length += 2 + (point.type == .Straight ? 1 : 4)
        }
        
        self._vertices = Array<Float32>(repeating: 0.0, count: length)
        var readIdx = 0
        reader.openArray(label: "value")
        for point in pathNode.points {
            _vertices[readIdx] = reader.readFloat32(label: "translationX")
            readIdx += 1
            _vertices[readIdx] = reader.readFloat32(label: "translationY")
            readIdx += 1
            if point.type == PointType.Straight {
                // radius
                _vertices[readIdx] = reader.readFloat32(label: "radius")
                readIdx += 1
            } else {
                // in/out
                _vertices[readIdx] = reader.readFloat32(label: "inValueX")
                readIdx += 1
                _vertices[readIdx] = reader.readFloat32(label: "inValueY")
                readIdx += 1
                _vertices[readIdx] = reader.readFloat32(label: "outValueX")
                readIdx += 1
                _vertices[readIdx] = reader.readFloat32(label: "outValueY")
                readIdx += 1
            }
        }
        reader.closeArray()
        
        pathNode.makeVertexDeform()
        
        return true
    }
    
   
    
}
