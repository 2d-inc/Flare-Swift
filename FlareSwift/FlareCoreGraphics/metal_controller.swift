//
//  metal_controller.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 3/20/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Metal
import MetalKit

class MetalController {
    private(set) var device: MTLDevice!
    private(set) var pipelineState: MTLRenderPipelineState!
    private(set) var commandQueue: MTLCommandQueue!
    private(set) var viewMatrix: [Float]!
    private(set) var transformMatrix: [Float]!
    private(set) var projectionMatrix: [Float]!

    private(set) var textureLoader: MTKTextureLoader! = nil
    
    var viewTransform: [Float] {
        get {
            return viewMatrix
        }
        set(view) {
            if viewMatrix[0] != view[0] &&
            viewMatrix[1] != view[1] &&
            viewMatrix[4] != view[2] &&
            viewMatrix[5] != view[3] &&
            viewMatrix[12] != view[4] &&
            viewMatrix[13] != view[5]
            {
                return
            }

            viewMatrix[0] = view[0]
            viewMatrix[1] = view[1]
            viewMatrix[4] = view[2]
            viewMatrix[5] = view[3]
            viewMatrix[12] = view[4]
            viewMatrix[13] = view[5]
        }
    }
    
    init() {
        device = MTLCreateSystemDefaultDevice()
        textureLoader = MTKTextureLoader(device: device)
        
        projectionMatrix = [Float](repeating: 0, count: 16)
        viewMatrix = [
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        ]
        transformMatrix = [
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        ]
        
        let frameworkBundle = Bundle(for: type(of: self))
//        let defaultLibrary = device.makeDefaultLibrary()!
        let defaultLibrary = try! device.makeDefaultLibrary(bundle: frameworkBundle)
//        print("GOT THE FUNCTIONS? \(defaultLibrary.functionNames)")
        let fragmentProgram = defaultLibrary.makeFunction(name: "textured_simple")
        let vertexProgram = defaultLibrary.makeFunction(name: "regular_vertex")
//        let fragmentProgram = defaultLibrary.makeFunction(name: "fragment_interpolation")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexProgram
        pipelineDescriptor.fragmentFunction = fragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .destinationAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .destinationAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusBlendAlpha
        // TODO: blending options
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        commandQueue = device.makeCommandQueue()
    }
    
    func setViewportSize(width: Int, height: Int) {
        MetalController.ortho(matrix: &projectionMatrix, left: 0, right: Float(width), bottom: 0, top: Float(height), near: 0, far: 100)
    }
    
    
    func setBlendMode(/*_ mode: BlendMode*/) {
        // TODO:
    }
    
    static func ortho(matrix: inout [Float], left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) {
        let lr = 1/(left-right)
        let bt = 1/(bottom-top)
        let nf = 1/(near-far)
        matrix[0] = -2.0 * lr
        matrix[1] = 0
        matrix[2] = 0
        matrix[3] = 0
        matrix[4] = 0
        matrix[5] = -2.0 * bt
        matrix[6] = 0
        matrix[7] = 0
        matrix[8] = 0
        matrix[9] = 0
        matrix[10] = 2.0 * nf
        matrix[11] = 0
        matrix[12] = (left + right) * lr
        matrix[13] = (top + bottom) * bt
        matrix[14] = (far + near) * nf
        matrix[15] = 1.0
    }
}
