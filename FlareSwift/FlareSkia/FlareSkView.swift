//
//  FlareSkView.swift
//  FlareSkia
//
//  Created by Umberto Sonnino on 4/1/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import UIKit
import Foundation
import Skia

@IBDesignable
public class FlareSkView: UIView {
    
    private var _eaglLayer: CAEAGLLayer?
    private var _context: EAGLContext?
    private var _depthRenderBuffer = GLuint()
    private var _colorRenderBuffer = GLuint()
    
    var actor: FlareSkActor!
    private var _artboardInstance: FlareSkArtboard?
    private var animation: ActorAnimation?
    var setupAABB: AABB!
    
    private var shouldClip = true
    
    private var _skiaCanvas: OpaquePointer!
    private var _skiaSurface: OpaquePointer!
    private var _skBackgroundPaint: OpaquePointer!

    var artboard: FlareSkArtboard? {
        get { return _artboardInstance }
        set {
            if newValue != _artboardInstance {
                _artboardInstance = newValue
                _artboardInstance?.advance(seconds: 0.0)
            }
        }
    }
    
    override public class var layerClass: AnyClass {
        get {
            return CAEAGLLayer.self
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("FlareSkView init(coder:) Not Supported!")
    }
    
    private func setupLayer() {
        guard let glLayer = self.layer as? CAEAGLLayer else {
            fatalError("Couldn't get GL layer!")
        }
        
        glLayer.isOpaque = false
        _eaglLayer = glLayer
        
        setupContext()
    }
    
    private func setupContext() {
        guard let glContext = EAGLContext(api: .openGLES2) else {
            fatalError("Couldn't get GL Context")
        }
        
        guard EAGLContext.setCurrent(glContext) else {
            fatalError("GL Context could not be set as current!")
        }
        
        _context = glContext

        glGenRenderbuffers(1, &_colorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), _colorRenderBuffer)
        
        _context!.renderbufferStorage(Int(GL_RENDERBUFFER), from: _eaglLayer)
        
        var framebuffer: GLuint = 0
        glGenFramebuffers(1, &framebuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), _colorRenderBuffer)

        let width = Int32(frame.size.width)
        let height = Int32(frame.size.height)
        glViewport(0, 0, GLsizei(width), GLsizei(height))
        let info = sk_imageinfo_new(width, height, RGBA_8888_SK_COLORTYPE, OPAQUE_SK_ALPHATYPE, nil)
        _skiaSurface = sk_surface_new_gl(info)
        if _skiaSurface != nil {
            _skiaCanvas = sk_surface_get_canvas(_skiaSurface)
        }
        _skBackgroundPaint = sk_paint_new()
        sk_paint_set_color(_skBackgroundPaint, sk_color_set_argb(255, 93, 93, 93))
    }
    
    func updateBounds(with nodeName: String? = nil) {
        guard let artboard = artboard else { return }
        
        if let boundsNodeName = nodeName,
            let node = artboard.getNode(name: boundsNodeName) as? ActorDrawable {
            setupAABB = node.computeAABB()
        } else {
            setupAABB = artboard.artboardAABB()
        }
    }
    
    /// Perform any pre-painting operation, if needed.
    /// Override to perform custom operations.
    func prePaint() {
        if shouldClip {
            var clipRect = sk_rect_t()
            clipRect.left = 0
            clipRect.top = 0
            clipRect.right = Float(frame.width)
            clipRect.bottom = Float(frame.height)
            sk_canvas_clip_rect(_skiaCanvas, &clipRect)
        }
    }
    
    func postPaint() {}
    
    func paint() {
        if let artboard = self.artboard {
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
            
            let bounds = setupAABB!
            // Check for alignment:
            // self.alignmentRectInsets
            let contentsWidth = bounds.width
            let contentsHeight = bounds.height
            
            let tx = contentsWidth * artboard.origin.x
            let ty = contentsHeight * artboard.origin.y
            
            // Contain the Artboard
            let scaleX = Float(frame.size.width) / contentsWidth
            let scaleY = Float(frame.size.height) / contentsHeight
            let scale = min(scaleX, scaleY)
            
            sk_canvas_save(_skiaCanvas)
            
            prePaint()
            
            sk_canvas_scale(_skiaCanvas, scale, scale)
            sk_canvas_translate(_skiaCanvas, tx, ty)
            
            sk_canvas_draw_paint(_skiaCanvas, _skBackgroundPaint) // Clear the background.
            
            artboard.draw(skCanvas: _skiaCanvas)
            
            sk_canvas_restore(_skiaCanvas)
            
            postPaint()
            
            sk_canvas_flush(_skiaCanvas)
            
            glBindRenderbuffer(GLenum(GL_RENDERBUFFER), _colorRenderBuffer)
            _context!.presentRenderbuffer(Int(GL_RENDERBUFFER))
        }
    }

    
    // Debugging functions.
    func drawQuad(_ canvas: OpaquePointer) {
        sk_canvas_save(canvas)
        let path = sk_path_new()
        //
        let subpath = sk_path_new()
        sk_path_move_to(subpath, -236.0, -236.0)
        sk_path_line_to(subpath, 236, -236)
        sk_path_line_to(subpath, 236, 236)
        sk_path_line_to(subpath, -236, 236)
        sk_path_line_to(subpath, -236, -236)
        sk_path_close(subpath)
        
        var skMat = sk_matrix_t(
            mat: (
                0.5,    0.0,    236/2,
                0.0,    0.5,    372/2,
                0,      0,      1
            )
        )
        let matPointer = withUnsafeMutablePointer(to: &skMat){
            UnsafeMutablePointer($0)
        }
        sk_path_add_path_with_matrix(path, subpath, 0, 0, matPointer)
        
        let paint = sk_paint_new()
        sk_paint_set_antialias(paint, true)
        sk_paint_set_color(paint, sk_color_set_argb(0xFF, 0x00, 0xFF, 0xFF))
        sk_path_set_evenodd(path, false)
        
        sk_canvas_draw_path(canvas, path, paint)
        
        sk_path_delete(subpath)
        sk_path_delete(path)
        sk_paint_delete(paint)
        sk_canvas_restore(canvas)
        sk_canvas_flush(canvas)
    }
    
    func skiaDraw(_ canvas: OpaquePointer) {
        let fill = sk_paint_new()
        sk_paint_set_color(fill, sk_color_set_argb(0xFF, 0x00, 0x00, 0xFF))
        sk_canvas_draw_paint(canvas, fill)
        sk_paint_set_color(fill, sk_color_set_argb(0xFF, 0x00, 0xFF, 0xFF))
        var rect = sk_rect_t()
        rect.left = 100.0
        rect.top = 100.0
        rect.right = 724.0
        rect.bottom = 468

        sk_canvas_draw_rect(canvas, &rect, fill)

        let stroke = sk_paint_new()
        sk_paint_set_color(stroke, sk_color_set_argb(0xFF, 0xFF, 0x00, 0x00))
        sk_paint_set_antialias(stroke, true)
        sk_paint_set_stroke(stroke, true)
        sk_paint_set_stroke_width(stroke, 5.0)
        let path = sk_path_new()
        
        sk_path_move_to(path, 50, 50)
        sk_path_line_to(path, 774, 50)
        sk_path_cubic_to(path, -518, 50, 1470, 518, 50, 518)
        sk_path_line_to(path, 774, 518)
        sk_canvas_draw_path(canvas, path, stroke)
        
        sk_paint_set_color(fill, sk_color_set_argb(0x80, 0x00, 0xFF, 0x00))
        rect = sk_rect_t()
        rect.left = 120
        rect.top = 120
        rect.right = 704
        rect.bottom = 448
        sk_canvas_draw_oval(canvas, &rect, fill)
         
        sk_path_delete(path)
        sk_paint_delete(stroke)
        sk_paint_delete(fill)

        sk_canvas_flush(canvas)
    }
}
