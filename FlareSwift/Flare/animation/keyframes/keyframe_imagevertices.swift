//
//  keyframe_imagevertices.swift
//  Flare
//
//  Created by Umberto Sonnino on 3/19/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class KeyFrameImageVertices: Interpolated {
    var _interpolator: Interpolator?
    var _time: Double = 0.0
    
    private(set) var vertices: [Float]!
    private var _component: ActorImage
    
    func read(_ reader: StreamReader) -> Bool {
        if !self.readInterpolation(reader) {
            return false
        }
        self.vertices = [Float](repeating: 0.0, count: _component.vertexCount*2)
        reader.readFloat32ArrayOffset(ar: &self.vertices, length: self.vertices.count, offset: 0, label: "value");
        
        _component.doesAnimationVertexDeform = true
        return true
    }
    
    init(component: ActorComponent) {
        assert(component is ActorImage, "KeyFrameImageVertices::init() - Component was NOT an ActorImage!")
        self._component = component as! ActorImage
    }
    
    
    func applyInterpolation(component: ActorComponent, time: Double, toFrame: KeyFrame, mix: Float) {
        let imageNode = _component
        let to = (toFrame as! KeyFrameImageVertices).vertices!
        let c = vertices.count
        var wr = [Float32](repeating: 0.0, count: c)
        
        var f = Float((time - _time) / (toFrame._time - _time))
        if _interpolator != nil {
            f = _interpolator!.getEasedMix(mix: f)
        }
        
        let fi = 1.0 - f
        if (mix == 1.0) {
            for i in 0 ..< c {
                wr[i] = vertices[i] * fi + to[i] * f
            }
        } else {
            let mixi = 1.0 - mix;
            for i in 0 ..< c {
                let v = vertices[i] * fi + to[i] * f
                
                wr[i] = wr[i] * mixi + v * mix
            }
        }
        
        imageNode.animationDeformedVertices = wr
        
        imageNode.invalidateDrawable()
    }
    
    func apply(component: ActorComponent, mix: Float) {
        let imageNode = _component
        let c = vertices.count
        var wr = [Float](repeating: 0.0, count: c)
        if (mix == 1.0) {
            for i in 0 ..< c {
                wr[i] = vertices[i]
            }
        } else {
            let mixi = 1.0 - mix;
            for i in 0 ..< c {
                wr[i] = wr[i] * mixi + vertices[i] * mix
            }
        }
        
        imageNode.animationDeformedVertices = wr
        
        imageNode.invalidateDrawable()
    }
    
    func setNext(_ frame: KeyFrame) { // Do Nothing
    }
}
