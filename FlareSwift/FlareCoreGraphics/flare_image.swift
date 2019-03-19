//
//  flare_image.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 3/19/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import MetalKit

class Vertex {
    var x,y: Float
    var s,t: Float
    
    init(_ x: Float, _ y: Float, _ s: Float, _ t: Float) {
        self.x = x
        self.y = y
        self.s = s
        self.t = t
    }
    
}

class FlareImage: ActorImage, FlareDrawable {
    let device: MTLDevice
    let _textureLoader: MTKTextureLoader
    var _samplerState: MTLSamplerState
    var _mtlBuffer: MTLBuffer!
    var _texture: MTLTexture!
    
    var _vertexBuffer: [Float]?
    var _uvBuffer: [Float]?
    var _indices: [Int32]?
    var _metalVertices: [Float]?
    
    init(device: MTLDevice, textureLoader: MTKTextureLoader) {
        self.device = device
        self._textureLoader = textureLoader
        let samplerDesc = MTLSamplerDescriptor()
        samplerDesc.minFilter = .nearest
        samplerDesc.magFilter = .nearest
        samplerDesc.mipFilter = .nearest
        samplerDesc.maxAnisotropy = 1
        samplerDesc.sAddressMode = .clampToEdge
        samplerDesc.tAddressMode = .clampToEdge
        samplerDesc.rAddressMode = .clampToEdge
        samplerDesc.normalizedCoordinates = true
        samplerDesc.lodMinClamp = 0
        samplerDesc.lodMaxClamp = .greatestFiniteMagnitude
        _samplerState = device.makeSamplerState(descriptor: samplerDesc)!
        super.init()
    }
    
    var _identityMatrix: [Float64] = [
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        0,0,0,1
    ]
    
    var textureIndex: Int {
        get { return _textureIndex }
        set {
            if _textureIndex != newValue {
                // TODO: set the new texture as the correct value
            }
        }
    }
    
    func dispose() {
        _uvBuffer = nil
        _vertexBuffer = nil
        _indices = nil
    }
    
    func draw(context: CGContext) {
        // TODO:
    }
    
    override func initializeGraphics() {
        guard let tris = triangles else {
            return
        }
        
        _vertexBuffer = makeVertexPositionBuffer()
        _uvBuffer = makeVertexUVBuffer()
        _indices = tris.map({ Int32($0) })
        updateVertexUVBuffer(buffer: &_uvBuffer!)
//        let count = vertexCount
//        var idx = 0
        
        // Create Texture
        let actor = (artboard!.actor as! FlareActor)
        let currentTextureData = actor.images![textureIndex]
        self._texture = try! _textureLoader.newTexture(data: currentTextureData, options:[MTKTextureLoader.Option.SRGB: 0])
        
        // TODO: set blendMode
/*        ui.Image image = (artboard.actor as FlutterActor).images[textureIndex];
        
        // SKIA requires texture coordinates in full image space, not traditional normalized uv coordinates.
        for (int i = 0; i < count; i++) {
            _uvBuffer[idx] = _uvBuffer[idx] * image.width;
            _uvBuffer[idx + 1] = _uvBuffer[idx + 1] * image.height;
            idx += 2;
        }
        
        if (this.sequenceUVs != null) {
            for (int i = 0; i < this.sequenceUVs.length; i++) {
                this.sequenceUVs[i++] *= image.width;
                this.sequenceUVs[i] *= image.height;
            }
        }
        
        _paint = ui.Paint()
            ..blendMode = blendMode
            ..shader = ui.ImageShader(
            (artboard.actor as FlutterActor).images[textureIndex],
            ui.TileMode.clamp,
            ui.TileMode.clamp,
            _identityMatrix);
            _paint.filterQuality = ui.FilterQuality.low;
            _paint.isAntiAlias = true;
 */
    }
    
    override func invalidateDrawable() {
        self._vertexBuffer = nil
    }
    
    func updateVertices() -> Bool {
        guard triangles != nil else {
            return false
        }
        
        self.updateVertexPositionBuffer(buffer: &_vertexBuffer!, isSkinnedDeformInWorld: false)
        
        var readIdx = 0
        let vb = _vertexBuffer!
        let ub = _uvBuffer!
        
        self._metalVertices = [Float]()
        for _ in 0 ..< vertexCount {
            self._metalVertices! += [
                vb[readIdx], vb[readIdx+1], // x,y
                ub[readIdx], ub[readIdx+1]  // u,v
            ]
            
            readIdx += 2
        }
        
        // Create vertex buffer
        let bufferLength = self._metalVertices!.count * MemoryLayout.size(ofValue: self._metalVertices![0])
        self._mtlBuffer = device.makeBuffer(bytes: self._metalVertices!, length: bufferLength, options: [])!
        
        return true
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceNode = FlareImage(device: self.device, textureLoader: self._textureLoader)
        instanceNode.copyImage(self, resetArtboard)
        return instanceNode
    }
    
    override func computeAABB() -> AABB {
        _ = self.updateVertices()
        
        var minX = Float.greatestFiniteMagnitude
        var minY = Float.greatestFiniteMagnitude
        var maxX = -Float.greatestFiniteMagnitude
        var maxY = -Float.greatestFiniteMagnitude
        
        var readIdx = 0
        
        if let vb = _vertexBuffer {
            let nv = vb.count / 2
            for _ in 0 ..< nv {
                let x = _vertexBuffer![readIdx]
                readIdx += 1
                let y = _vertexBuffer![readIdx]
                readIdx += 1
                if x < minX {
                    minX = x
                }
                if y < minY {
                    minY = y
                }
                if x > maxX {
                    maxX = x
                }
                if y > maxY {
                    maxY = y
                }
            }
        }
        
        return AABB.init(fromValues: minX, minY, maxX, maxY)
    }
    
}
