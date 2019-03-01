//
//  actor_image.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

struct BoneConnection {
    var boneIdx: Int
    var node: ActorNode?
    var bind = Mat2D()
    var inverseBind = Mat2D()
}

struct SequenceFrame {
    var atlasIndex: Int
    var offset: Int
}

public class ActorImage: ActorNode, ActorDrawable {
    public var _drawOrder: Int = -1 // Must be public b/c of ActorDrawable
    public var drawOrder: Int {
        get {
            return _drawOrder
        }
        set {
            _drawOrder = newValue
        }
    }
    
    public var drawIndex: Int = -1
    
    private var blendMode: BlendModes = .Normal
    private var _textureIndex = -1
    private var _vertexCount = 0
    private var _triangleCount = 0
    private var _vertices: [Float32]?
    private var _animationDeformedVertices: [Float32]?
    private var _triangles: [UInt16]?
    
    private var _boneConnections: [BoneConnection]?
    private var _boneMatrices: [Float32]?
    
    private var _sequenceFrames: [SequenceFrame]?
    private var _sequenceUVs: [Float32]?
    var sequenceFrame = -1
    
    var isVertexDeformDirty = false
    
    var sequenceUVs: [Float32]? {
        return _sequenceUVs
    }
    
    var sequenceFrames: [SequenceFrame]? {
        return _sequenceFrames
    }
    
    // TODO: rest of the class
    
    public func computeAABB() -> AABB {
        // TODO: implement for image.
        let wt = self.worldTransform
        return AABB.init(fromValues: wt[4], wt[5], wt[4], wt[5])
    }
    
    public func initializeGraphics() {}
    
}
