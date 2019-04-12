//
//  flare_cg_image.swift
//  FlareCoreGraphics
//
//  Created by Umberto Sonnino on 3/19/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import MetalKit
import QuartzCore

class FlareCGImage: ActorImage, FlareCGDrawable {
    
    let _metalController: MetalController
    let _samplerState: MTLSamplerState
    let _metalLayer: CAMetalLayer!
    
    var _metalVertexBuffer: MTLBuffer!
    var _metalDeformBuffer: MTLBuffer?
    var _metalIndexBuffer: MTLBuffer!
    var _metalUniformsBuffer: MTLBuffer!
    var _texture: MTLTexture!
    
    var _vertexBuffer: [Float]?
    var _uvBuffer: [Float]?
    var _indices: [Int32]?
    var _metalVertices: [Float]?
    
    var _isValid: Bool = false
    
    var lastDisplayedDrawable: CAMetalDrawable?
    
//    var _timeToImages: [Double: CGImage]?
    var _displayImage: CGImage?
    
    init(_ metalController: MetalController) {
        _metalController = metalController

        _metalLayer = CAMetalLayer()
        _metalLayer.device = _metalController.device!
        _metalLayer.pixelFormat = .bgra8Unorm_srgb
        _metalLayer.framebufferOnly = false
        _metalLayer.isOpaque = false
        
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
        _samplerState = _metalController.device.makeSamplerState(descriptor: samplerDesc)!
        super.init()
    }
    
    let _identityMatrix: [Float64] = [
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        0,0,0,1
    ]
    
    var textureIndex: Int {
        get { return _textureIndex }
        set {
            if _textureIndex != newValue {
                let actor = (artboard!.actor as! FlareCGActor)
                self._texture = _metalController.generateTexture(actor.images![textureIndex])
            }
        }
    }
    
    func dispose() {
        _uvBuffer = nil
        _vertexBuffer = nil
        _indices = nil
    }
    
    private func render() {
        guard self.updateVertices() else {
            return
        }
        
        guard let drawable = _metalLayer.nextDrawable() else {
            return
        }
        
        let commandQ = _metalController.commandQueue!
        let pipelineState = _metalController.pipelineState!
        
        self.updateWorldTransform()
        
        let renderDescriptor = MTLRenderPassDescriptor()
        renderDescriptor.colorAttachments[0].texture = drawable.texture
        renderDescriptor.colorAttachments[0].loadAction = .clear
        renderDescriptor.colorAttachments[0].storeAction = .store
        renderDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0.5, blue: 0, alpha: 0.2)
        
        let commandBuffer = commandQ.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor)!
        renderEncoder.setViewport(_metalController.viewport)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(_metalVertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(_metalUniformsBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentTexture(_texture, index: 0)
        renderEncoder.setFragmentSamplerState(_samplerState, index: 0)
        
        renderEncoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: triangles!.count,
            indexType: .uint16,
            indexBuffer: self._metalIndexBuffer,
            indexBufferOffset: 0
        )
        renderEncoder.endEncoding()
        
//        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        self._displayImage = drawable.texture.toCGImage()
    }
    
//    func draw(context: CGContext) {
    func draw(context: CGContext, on: CALayer) {
        autoreleasepool{
            if !_metalLayer.bounds.equalTo(on.bounds) {
                _metalLayer.frame = on.bounds
                _metalLayer.removeFromSuperlayer()
                on.addSublayer(_metalLayer)
                let width = Float(on.bounds.width)
                let height = Float(on.bounds.height)
                _metalController.setViewportSize(width: width, height: height)
                let scale = min(width/artboard!.width, height/artboard!.height)
                _metalController.setViewMatrix(x: 0, y: Float(height), scale: scale)
                self.invalidateDrawable()
            }
            if !isConnectedToBones {
                _metalController.prepare(transform: self.worldTransform)                
            }
//            _metalLayer.compositingFilter = CIFilter(name: "CIDarkenBlendMode")
            
//            let filter = CIFilter(name: "CIDarkenBlendMode")
            self.render()
//            _metalLayer.render(in: context)
//            let contents = _metalLayer.contents as! CAImageQueue
//            let image = _metalLayer.contents as! CABackingStore
//            context.draw(image, in: on.bounds)
        }
    }
    
    func renderOffscreen(rect: CGRect) {
        autoreleasepool{
            if !_metalLayer.bounds.equalTo(rect) {
                _metalLayer.frame = rect
                let width = Float(rect.width)
                let height = Float(rect.height)
                _metalController.setViewportSize(width: width, height: height)
                let scale = min(width/artboard!.width, height/artboard!.height)
                _metalController.setViewMatrix(x: 0, y: Float(height), scale: scale)
                self.invalidateDrawable()
            }
            if !isConnectedToBones {
                _metalController.prepare(transform: self.worldTransform)
            }
            self.render()
        }
    }
    
    override func initializeGraphics() {
        guard let tris = triangles else {
            return
        }
        
        // TODO: move Weights Calculations to the GPU

        // TODO: optimize this w/ swapping buffers.
        // Create vertex buffer
        let device = _metalController.device!
        let actor = (artboard!.actor as! FlareCGActor)
        
        // Each Vertex has (x,y) coordinates.
        let vbl = vertexCount * 2 * MemoryLayout<Float>.stride
        _metalVertexBuffer = device.makeBuffer(length: vbl, options: [])!
        // Create Texture
        let ibl = tris.count * MemoryLayout.stride(ofValue: tris[0])
        _metalIndexBuffer = device.makeBuffer(length: ibl, options: [])
        // MVP: Three 4x4 matrices.
        let ubl = MemoryLayout<Float>.stride * 16 * 3
        _metalUniformsBuffer = device.makeBuffer(length: ubl, options: [])!
        
        _ = updateVertices()
        
        _texture = _metalController.generateTexture(actor.images![textureIndex])
        
        _uvBuffer = makeVertexUVBuffer()
        _indices = tris.map({ Int32($0) })
//        if doesAnimationVertexDeform {
//            let deformedVertices = animationDeformedVertices!
//            // 2 floats per deform data - i.e. x,y translation values.
//            let size = vertexCount * 2 * MemoryLayout.size(ofValue: deformedVertices[0])
//            self._metalDeformBuffer = _metalController.device.makeBuffer(bytes: deformedVertices, length: size, options: [])
//        } else {
//
//        }
        
        // TODO: set blendMode
    }
    
    override func invalidateDrawable() {
        self._isValid = false
    }
    
    func updateVertices() -> Bool {
        guard
            let tris = triangles,
            !_metalLayer.frame.equalTo(CGRect.zero)
        else {
            return false
        }

        guard !self._isValid else {
            // Still valid.
            return true
        }
        
        self._isValid = true
        _vertexBuffer = makeVertexPositionBuffer()
        self.updateVertexPositionBuffer(buffer: &_vertexBuffer!, isSkinnedDeformInWorld: false)
        self.updateVertexUVBuffer(buffer: &_uvBuffer!)
        
        var readIdx = 0
        let vb = _vertexBuffer!
        let ub = _uvBuffer!
        
        var vertices = [Float]()
        for _ in 0 ..< vertexCount {
            let x = vb[readIdx],
                y = vb[readIdx+1]
            let u = ub[readIdx],
                v = ub[readIdx+1]
            vertices += [ x, y, u, v ]
            
            readIdx += 2
        }
        
        self._metalVertices = vertices
        let vbc = vertices.count * MemoryLayout.stride(ofValue: vertices[0])
        _metalVertexBuffer.contents()
            .copyMemory(from: vertices, byteCount: vbc)
        
        let ibc = tris.count * MemoryLayout.stride(ofValue: tris[0])
        _metalIndexBuffer.contents()
            .copyMemory(from: tris, byteCount: ibc)
        
        
        let bufPointer = _metalUniformsBuffer.contents()
        let worldMatrix = _metalController.transformMatrix
        let viewMatrix = _metalController.viewMatrix
        let projectionMatrix = _metalController.projectionMatrix
        
        let matrixSize = MemoryLayout<Float>.stride * 16
        memcpy(bufPointer, worldMatrix, matrixSize)
        memcpy(bufPointer + matrixSize, viewMatrix, matrixSize)
        memcpy(bufPointer + (matrixSize*2), projectionMatrix, matrixSize)

        return true
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceNode = FlareCGImage(_metalController)
        instanceNode.copyImage(self, resetArtboard)
        return instanceNode
    }
    
    private var bounds: AABB {
        get {
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
    
    override func computeAABB() -> AABB {
        _ = self.updateVertices()
        return self.bounds
    }    
}
