//
//  actor_image.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class BoneConnection {
    var boneIdx: Int!
    var node: ActorNode?
    var bind = Mat2D()
    var inverseBind = Mat2D()
}

class SequenceFrame {
    var atlasIndex: Int!
    var offset: Int!
}

public class ActorImage: ActorNode, ActorSkinnable, ActorDrawable {
    
    public var _drawOrder: Int = -1 // Must be public b/c of ActorDrawable
    public var drawOrder: Int {
        get {
            return _drawOrder
        }
        set {
            _drawOrder = newValue
        }
    }
    
    var skin: ActorSkin?
    var _connectedBones: [SkinnedBone]?
    public var isHidden: Bool = false
    public var blendModeId: Int {
        get {
            return 0
        }
        set {}
    }
    public var _clipShapes: [[ActorShape]]?
    public var drawIndex: Int = -1
    
    var imageTransform: Mat2D? {
        return isConnectedToBones ? nil : worldTransform
    }
    var animationDeformedVertices: [Float32]?
    
    private var blendMode: BlendModes = .Normal
    private(set) var _textureIndex = -1
    private(set) var vertexCount = 0
    private(set) var triangleCount = 0
    private(set) var vertices: [Float32]?
    private(set) var triangles: [UInt16]?
    
    private var _boneConnections: [BoneConnection]?
    private var _boneMatrices: [Float32]?
    
    private(set) var sequenceFrames: [SequenceFrame]?
    private(set) var sequenceUVs: [Float32]?
    var sequenceFrame = 0
    
    var isVertexDeformDirty = false
    
    var vertexPositionOffset: Int { return 0 }
    var vertexUVOffset: Int { return 2 }
    var vertexBoneIndexOffset: Int { return 4 }
    var vertexBoneWeightOffset: Int { return 8 }
    var vertexStride: Int { return isConnectedToBones ? 12 : 4 }
    
    var doesAnimationVertexDeform: Bool {
        get {
            return animationDeformedVertices != nil
        }
        set {
            if newValue {
                if animationDeformedVertices != nil || animationDeformedVertices!.count != vertexCount * 2 {
                    animationDeformedVertices = [Float]()
                    var writeIdx = 0
                    var readIdx = 0
                    let readStride = vertexStride
                    for _ in 0..<vertexCount {
                        animationDeformedVertices?.insert(vertices![readIdx], at: writeIdx)
                        writeIdx += 1
                        animationDeformedVertices?.insert(vertices![readIdx+1], at: writeIdx)
                        writeIdx += 1
                        readIdx += readStride
                    }
                }
            } else {
                animationDeformedVertices = nil
            }
        }
    }
    
    func disposeGeometry() {
        if let _ = self.animationDeformedVertices {
            vertices = nil
        }
        triangles = nil
    }
    
    func readImage(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readDrawable(artboard, reader)
        self.readSkinnable(artboard, reader)
        
        if self.isHidden {
            self._textureIndex = Int(reader.readUint8(label: "atlas"))
            let numVerts = Int(reader.readUint32(label: "numVertices"))
            
            self.vertexCount = numVerts
            self.vertices = [Float].init(repeating: 0.0, count: numVerts*self.vertexStride)
            reader.readFloat32ArrayOffset(ar: &self.vertices!, length: self.vertices!.count, offset: 0, label: "vertices")
            
            let numTris = Int(reader.readUint32(label: "numTriangles"))
            self.triangles = Array<UInt16>.init(repeating: UInt16(0.0), count: numTris*3)
            self.triangleCount = numTris
            reader.readUint16Array(ar: &self.triangles!, length: self.triangles!.count, offset: 0, label: "triangles")
        }
    }
    
    override func resolveComponentIndices(_ components: [ActorComponent?]) {
        super.resolveComponentIndices(components)
        resolveSkinnable(components)
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceNode = ActorImage()
        instanceNode.copyImage(self, resetArtboard)
        return instanceNode
    }
    
    func copyImage(_ node: ActorImage, _ resetArtboard: ActorArtboard) {
        self.copyDrawable(node, resetArtboard)
        self.copySkinnable(node, resetArtboard)
        
        _textureIndex = node._textureIndex
        vertexCount = node.vertexCount
        triangleCount = node.triangleCount
        vertices = node.vertices
        triangles = node.triangles
        if let adv = node.animationDeformedVertices {
            animationDeformedVertices = adv // Array is struct and copies it over.
        }
    }
    
    func makeVertexPositionBuffer() -> [Float] {
        return [Float](repeating: 0, count: vertexCount*2)
    }
    
    func makeVertexUVBuffer() -> [Float] {
        return [Float](repeating: 0, count: vertexCount*2)
    }
    
    func transformDeformVertices(_ wt: Mat2D) {
        guard var adv = animationDeformedVertices else {
            return
        }
        
        var vidx = 0
        for _ in 0 ..< vertexCount {
            let x = adv[vidx]
            let y = adv[vidx+1]
            
            adv[vidx] = wt[0] * x + wt[2] * y + wt[4]
            adv[vidx+1] = wt[1] * x + wt[3] * y + wt[5]
            
            vidx += 2
        }
        
        // Array is a struct, so we need to copy it back.
        animationDeformedVertices = adv
    }
    
    func updateVertexUVBuffer(buffer: inout [Float]) {
        var readIdx = vertexUVOffset
        var writeIdx = 0
        let stride = vertexStride
        
        for _ in 0 ..< vertexCount {
            buffer[writeIdx] = vertices![readIdx]
            writeIdx += 1
            buffer[writeIdx] = vertices![readIdx+1]
            writeIdx += 1
            readIdx += stride
        }
    }
    
    func updateVertexPositionBuffer(buffer: inout [Float], isSkinnedDeformInWorld: Bool) {
        let worldTransform = self.worldTransform
        var readIdx = 0
        var writeIdx = 0
        
        let v = (animationDeformedVertices ?? vertices)!
        let stride = animationDeformedVertices != nil ? 2 : vertexStride
        
        if let s = skin {
            let boneTransforms = s.boneMatrices
            var influenceMatrix: [Float] = [0,0,0,0,0,0]
            var boneIndexOffset = vertexBoneIndexOffset
            var weightOffset = vertexBoneWeightOffset
            
            for _ in 0 ..< vertexCount {
                var x = v[readIdx]
                var y = v[readIdx + 1]
                
                var px: Float, py: Float
                
                if animationDeformedVertices != nil && isSkinnedDeformInWorld {
                    px = x;
                    py = y;
                } else {
                    px = worldTransform[0] * x + worldTransform[2] * y + worldTransform[4];
                    py = worldTransform[1] * x + worldTransform[3] * y + worldTransform[5];
                }
                
                influenceMatrix = [0,0,0,0,0,0]
                
                for wi in 0 ..< 4 {
                    let boneIndex = Int(vertices![boneIndexOffset + wi])
                    let weight = vertices![weightOffset + wi]
                    
                    let boneTransformIndex = boneIndex * 6
                    if boneIndex <= connectedBones!.count {
                        for j in 0 ..< 6 {
                            influenceMatrix[j] += boneTransforms![boneTransformIndex + j] * weight
                        }
                    } else {
                        print("BAD BONE INDEX \(boneIndex) \(connectedBones!.count) \(name)");
                    }
                }
                
                x = influenceMatrix[0] * px + influenceMatrix[2] * py + influenceMatrix[4]
                y = influenceMatrix[1] * px + influenceMatrix[3] * py + influenceMatrix[5]
                
                readIdx += stride
                boneIndexOffset += vertexStride
                weightOffset += vertexStride
                
                buffer[writeIdx] = x
                writeIdx += 1
                buffer[writeIdx] = y
                writeIdx += 1
            }
        } else {
            for _ in 0 ..< vertexCount {
                buffer[writeIdx] = v[readIdx]
                writeIdx += 1
                buffer[writeIdx] = v[readIdx + 1]
                writeIdx += 1
                readIdx += stride
            }
        }
    }
    
    public func computeAABB() -> AABB {
        // TODO: implement for image.
        let wt = self.worldTransform
        return AABB.init(fromValues: wt[4], wt[5], wt[4], wt[5])
    }
    
    public func initializeGraphics() {}
    func invalidateDrawable() {}
    
}
