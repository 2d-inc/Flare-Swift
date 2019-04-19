//
//  keyframe_vertex_deform.swift
//  FlareCore
//
//  Created by Umberto Sonnino on 2/18/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class KeyFrameVertexDeform: Interpolated {
    var _interpolator: Interpolator?
    
    var _time: Double = 0.0
    
    var _vertices: [Float]?
    
    var vertices: [Float]? {
        return _vertices
    }
    
    func applyInterpolation(component: ActorComponent, time: Double, toFrame: KeyFrame, mix: Float) {
        // TODO:
    }
    
    func apply(component: ActorComponent, mix: Float) {
        // TODO:
    }
    
    func setNext(_ frame: KeyFrame) {
        // Do nothing.
    }
    
    func read(_ reader: StreamReader) -> Bool {
        if !readInterpolation(reader) {
            return false
        }
        
        // TODO: when ActorImages
//        let imageNode = component as ActorImage
        return true
    }
    
}
