//
//  flare_sk_image.swift
//  FlareSkia
//
//  Created by Umberto Sonnino on 3/19/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import Skia

enum FilterQuality: UInt32 {
    case none = 0, low, medium, high
}

public class FlareSkImage: ActorImage, FlareSkDrawable {
    var _blendMode: BlendMode = .SrcOver
    
    var _vertexBuffer: [Float]!
    var _uvBuffer: [Float]!
    var _indices: [Int32]!
    
    /// `sk_paint_t*` for the current image.
    var _paint: OpaquePointer!
    /// `sk_vertices_t*` for this mesh.
    var _canvasVertices: OpaquePointer!
    
    var textureIndex: Int {
        get { return _textureIndex }
        set {
            if _textureIndex != newValue {
                _textureIndex = newValue
                let actor = (artboard!.actor as! FlareSkActor)
                let skImage = actor.images![_textureIndex]
                let shader = sk_shader_new_image(skImage)
                sk_paint_set_xfermode_mode(_paint, blendMode.skType)
                sk_paint_set_shader(_paint, shader)
                sk_shader_unref(shader)
                sk_paint_set_filterquality(_paint, FilterQuality.low.rawValue)
                sk_paint_set_antialias(_paint, true)
                onPaintUpdated(_paint)
            }
        }
    }
    
    /// Force drawables to use the concrete implementation.
    override public var blendModeId: UInt32 {
        get {
            return (self as FlareSkDrawable).blendModeId
        }
        set {
            (self as FlareSkDrawable).blendModeId = newValue
        }
    }
    
    func dispose() {
        _uvBuffer = nil
        _vertexBuffer = nil
        _indices = nil
        sk_paint_delete(_paint)
        sk_vertices_unref(_canvasVertices)
    }
    
    func onBlendModeChanged(_ mode: BlendMode) {
        guard let paint = _paint else { return }
        sk_paint_set_xfermode_mode(_paint, mode.skType)
        onPaintUpdated(paint)
    }

    /// Update the canvas vertices to correctly display a dynamic image.
    func changeImage(with image: OpaquePointer) -> Bool {
        guard
            triangles != nil,
            let dynamicUV = dynamicUV
        else { return false }
        
        _uvBuffer = makeVertexUVBuffer()
        let vCount = Int32(vertexCount)
        
        let imageWidth = Float(sk_image_get_width(image))
        let imageHeight = Float(sk_image_get_height(image))
        
        var idx = 0
        for _ in 0 ..< vCount {
            _uvBuffer[idx] = dynamicUV[idx] * imageWidth
            _uvBuffer[idx + 1] = dynamicUV[idx + 1] * imageHeight
            idx += 2
        }

        invalidateDrawable()
        
        let shader = sk_shader_new_image(image)
        sk_paint_set_shader(_paint, shader)
        sk_shader_unref(shader)
        
        // Make sure that vb has been populated.
        updateVertexPositionBuffer(buffer: &_vertexBuffer, isSkinnedDeformInWorld: false)
        
        _canvasVertices = sk_vertices_new(
            _vertexBuffer,
            vCount,
            _uvBuffer,
            _indices,
            Int32(_indices.count)
        )

        onPaintUpdated(_paint)
        
        return true
    }
    
    /// Update the image of this FlareSkImage with the contents
    /// of a PNG or a JPG file located at the parameter URL.
    public func changeImageFrom(url: String) {
        let imageURL = URL(string: url)!
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: imageURL) { (data, res, err) in
            if let imageData = data {
                let uiImg = UIImage(data: imageData)
                if let pngData = uiImg?.pngData() {
                    pngData.withUnsafeBytes{ (buffer: UnsafeRawBufferPointer) in
                        let skData = sk_data_new_with_copy(buffer.baseAddress, pngData.count)
                        if let skImage = sk_image_new_from_encoded(skData, nil) {
                            _ = self.changeImage(with: skImage)
                            sk_image_unref(skImage)
                        }
                        sk_data_unref(skData)
                    }
                }
            }
        }
        // Start download.
        task.resume()
    }
    
    /// Update the image of this FlareSkImage with the contents
    /// of a file in the bundle.
    public func changeImageFrom(bundle: Bundle, with filename: String) {
        if let fileURL = bundle.path(forResource: filename, ofType: "") {
            if let imageData = FileManager.default.contents(atPath: fileURL) {
                imageData.withUnsafeBytes{ (buffer: UnsafeRawBufferPointer) in
                    let skData = sk_data_new_with_copy(buffer.baseAddress, imageData.count)
                    let skImage = sk_image_new_from_encoded(skData, nil)!
                    _ = self.changeImage(with: skImage)
                    sk_image_unref(skImage)
                    sk_data_unref(skData)
                }
            }
        }
    }
    
    override public func initializeGraphics() {
        super.initializeGraphics()
        guard let tris = triangles else {
            return
        }
        
        _vertexBuffer = makeVertexPositionBuffer()
        _uvBuffer = makeVertexUVBuffer()
        _indices = []
        for val in tris {
            _indices.append(Int32(val))
        }
        updateVertexUVBuffer(buffer: &_uvBuffer)
        let count = vertexCount
        var idx = 0
        
        _paint = sk_paint_new()
        sk_paint_set_xfermode_mode(_paint, blendMode.skType)
        
        if let images = (artboard!.actor as! FlareSkActor).images {
            let image = images[textureIndex]
            let imageWidth = Float(sk_image_get_width(image))
            let imageHeight = Float(sk_image_get_height(image))
            
            // SKIA requires texture coordinates in full image space, not traditional
            // normalized uv coordinates.
            for _ in 0 ..< count {
                _uvBuffer[idx] *= imageWidth
                _uvBuffer[idx + 1] *= imageHeight
                idx += 2
            }
            
            if var suv = sequenceUVs {
                var i = 0
                while i < suv.count {
                    suv[i] *= imageWidth
                    i += 1
                    suv[i] *= imageWidth
                    i += 1
                }
            }

            let shader = sk_shader_new_image(image)
            sk_paint_set_shader(_paint, shader)
            sk_shader_unref(shader)
        }
        
        sk_paint_set_filterquality(_paint, FilterQuality.low.rawValue)
        sk_paint_set_antialias(_paint, true)
        onPaintUpdated(_paint)
    }
    
    override func invalidateDrawable() {
        guard _canvasVertices != nil else {
            return
        }
        sk_vertices_unref(_canvasVertices)
        _canvasVertices = nil
    }
    
    func updateVertices() -> Bool {
        guard triangles != nil else {
            return false
        }
        
        updateVertexPositionBuffer(buffer: &_vertexBuffer, isSkinnedDeformInWorld: false)
        let vCount = Int32(vertexCount)
        let iCount = Int32(_indices.count)
        _canvasVertices = sk_vertices_new(
            _vertexBuffer,
            vCount,
            _uvBuffer,
            _indices,
            iCount
        )
        
        return true
    }

    func draw(_ skCanvas: OpaquePointer) {
        if triangles == nil || renderCollapsed || renderOpacity <= 0 {
            return
        }
        
        if _canvasVertices == nil && !updateVertices() {
            return
        }
        
        sk_canvas_save(skCanvas)
        
        // Get Clips
        for clips in clipShapes {
            let clippingPath = sk_path_new()
            for clipShape in clips {
                let subClip = (clipShape as! FlareSkShape).path
                sk_path_add_path(clippingPath, subClip, 0, 0)
            }
            // bool flag enables antialiasing.
            sk_canvas_clip_path(skCanvas, clippingPath, true)
            sk_path_delete(clippingPath)
        }
        
        let color = sk_paint_get_color(_paint)
        let r = sk_color_get_r(color)
        let g = sk_color_get_g(color)
        let b = sk_color_get_b(color)
        let a = min(max((UInt32(renderOpacity) * 255), 0), 255)
        sk_paint_set_color(_paint, sk_color_set_argb(a, r, g, b))

        if let imgTransform = imageTransform {
            var skMat = sk_matrix_t(
                mat: (
                    imgTransform[0],
                    imgTransform[2],
                    imgTransform[4],
                    imgTransform[1],
                    imgTransform[3],
                    imgTransform[5],
                    0, 0, 1
                )
            )
            let matPointer = withUnsafePointer(to: &skMat) {
                UnsafePointer($0)
            }
            sk_canvas_concat(skCanvas, matPointer)
        }
        
        sk_canvas_draw_vertices(skCanvas, _canvasVertices, _paint)

        sk_canvas_restore(skCanvas)
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
    
    override public func computeAABB() -> AABB {
        _ = self.updateVertices()
        return self.bounds
    }
    
    /// Update the current paint with a new value.
    /// `skPaint` must be a `sk_paint_t*`
    func onPaintUpdated(_ skPaint: OpaquePointer){}
    
    override func update(dirt: UInt8) {
        super.update(dirt: dirt)
        if (dirt & DirtyFlags.PaintDirty != 0) {
            onPaintUpdated(_paint)
        }
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceImage = FlareSkImage()
        instanceImage.copyImage(self, resetArtboard)
        return instanceImage
    }
}
