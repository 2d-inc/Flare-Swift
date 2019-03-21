//
//  flare_image.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 3/19/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import CoreGraphics
import MetalKit


class FlareImage: ActorImage, FlareDrawable {
    
    let _metalController: MetalController
    let _samplerState: MTLSamplerState
    let _metalLayer: CAMetalLayer!
    
    var _metalVertexBuffer: MTLBuffer!
    var _metalIndexBuffer: MTLBuffer!
    var _texture: MTLTexture!
    
    var _vertexBuffer: [Float]?
    var _uvBuffer: [Float]?
    var _indices: [Int32]?
    var _metalVertices: [Float]?
    
    init(_ metalController: MetalController) {
        self._metalController = metalController

        _metalLayer = CAMetalLayer()
        _metalLayer.device = self._metalController.device!
        _metalLayer.pixelFormat = .bgra8Unorm
        _metalLayer.framebufferOnly = true
        
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
                // TODO: set the new texture as the correct value
            }
        }
    }
    
    func dispose() {
        _uvBuffer = nil
        _vertexBuffer = nil
        _indices = nil
    }
    
    private func render(_ on: CALayer) {
        guard self.updateVertices() else {
            return
        }
        
        guard let drawable = _metalLayer.nextDrawable() else {
            return
        }
        
        on.addSublayer(_metalLayer)
        
        let commandQ = _metalController.commandQueue!
        let pipelineState = _metalController.pipelineState!
        
        let renderDescriptor = MTLRenderPassDescriptor()
        renderDescriptor.colorAttachments[0].texture = drawable.texture
        renderDescriptor.colorAttachments[0].loadAction = .clear
        renderDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.25, green: 0.85, blue: 0.6, alpha: 1.0)
//        renderDescriptor.colorAttachments[0].storeAction = .store
        
        let commandBuffer = commandQ.makeCommandBuffer()!
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(_metalVertexBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentTexture(_texture, index: 0)
        renderEncoder.setFragmentSamplerState(_samplerState, index: 0)
        
        // TODO: MVP matrices into Uniform buffer
        renderEncoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: triangles!.count,
            indexType: .uint16,
            indexBuffer: self._metalIndexBuffer,
            indexBufferOffset: 0
        )
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        UIGraphicsGetCurrentContext()
        commandBuffer.commit()
    }
    
//    func draw(context: CGContext) {
    func draw(on: CALayer) {
        autoreleasepool{
            self.render(on)
        }
    }
    
    override func initializeGraphics() {
        guard let tris = triangles else {
            return
        }
        
//        _vertexBuffer = makeVertexPositionBuffer()
        _uvBuffer = makeVertexUVBuffer()
        _indices = tris.map({ Int32($0) })
        updateVertexUVBuffer(buffer: &_uvBuffer!)
        _ = self.updateVertices()
//        let count = vertexCount
//        var idx = 0
        
        // Create Texture
        let actor = (artboard!.actor as! FlareActor)
        let currentTextureData = actor.images![textureIndex]
        let loader = self._metalController.textureLoader!
        self._texture = try! loader.newTexture(data: currentTextureData, options:[
            MTKTextureLoader.Option.generateMipmaps: true,
            MTKTextureLoader.Option.allocateMipmaps: true
            ]
        )
        
        // TODO: set blendMode
    }
    
    override func invalidateDrawable() {
        self._vertexBuffer = nil
    }
    
    func updateVertices() -> Bool {
        guard let tris = triangles else {
            return false
        }
        
        guard self._vertexBuffer == nil else {
            // Still valid.
            return true
        }
        
        self._vertexBuffer = makeVertexPositionBuffer()
        self.updateVertexPositionBuffer(buffer: &_vertexBuffer!, isSkinnedDeformInWorld: false)
        
        var readIdx = 0
        let vb = _vertexBuffer!
        let ub = _uvBuffer!
        
        let bounds = self.bounds
        let width = bounds[2] - bounds[0]
        let height = bounds[3] - bounds[1]
        
        var vertices = [Float]()
        for _ in 0 ..< vertexCount {
            let x = vb[readIdx]/width
            let y = vb[readIdx+1]/height
            let u = ub[readIdx],
                v = ub[readIdx+1]
            vertices += [ x, y, u, v ]
            
            readIdx += 2
        }
        
        // TODO: optimize this w/ swapping buffers.
        // Create vertex buffer
        let bufferLength = vertices.count * MemoryLayout.size(ofValue: vertices[0])
        let device = self._metalController.device!
        self._metalVertexBuffer = device.makeBuffer(bytes: vertices, length: bufferLength, options: [])!
        self._metalVertices = vertices
        
        let indexBufferSize = tris.count * MemoryLayout.size(ofValue: tris[0])
        print(tris)
        self._metalIndexBuffer = device.makeBuffer(bytes: tris, length: indexBufferSize, options: [])
       
        print("TRANSLATION AT: \(self.translation.description) ADDING A FRAME OF WIDTH:\(width), HEIGHT:\(height)")
        
//        print("WILL NEED TO BE TRANSFORMED BY: \(self.worldTransform.description)")
        self._metalLayer.frame = CGRect(x: CGFloat(50), y: CGFloat(50), width: CGFloat(width), height: CGFloat(height/2.1))
        
        return true
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceNode = FlareImage(self._metalController)
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
