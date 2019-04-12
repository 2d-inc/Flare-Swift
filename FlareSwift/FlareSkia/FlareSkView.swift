//
//  FlareSkView.swift
//  FlareSwift
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
    
    override public class var layerClass: AnyClass {
        get {
            return CAEAGLLayer.self
        }
    }
    
    private var displayLink: CADisplayLink?
    
    private var _filename: String = ""
    
    private var flareActor: FlareSkActor!
    private var artboard: FlareSkArtboard?
    private var animation: ActorAnimation?
    private var setupAABB: AABB!
    private var animationName: String?
    
    private var lastTime = 0.0
    private var duration = 0.0
    private var animationTime = 0.0
    private var isPlaying = true
    private var shouldClip = true
    
    private var _color: CGColor?
    // TODO: animation layers
    
    private var _skiaCanvas: OpaquePointer!
    private var _skiaSurface: OpaquePointer!
    
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
            return
        }
        
        glLayer.isOpaque = true
        _eaglLayer = glLayer
        
        setupContext()
    }
    
    private func setupContext() {
        guard let glContext = EAGLContext(api: .openGLES2) else {
            fatalError("Couldn't get GL Context")
            return
        }
        
        guard EAGLContext.setCurrent(glContext) else {
            fatalError("GL Context could not be set as current!")
            return
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
        print("W/H \(frame.size.width)/\(frame.size.height)")
        let info = sk_imageinfo_new(width, height, RGBA_8888_SK_COLORTYPE, OPAQUE_SK_ALPHATYPE, nil)
        _skiaSurface = sk_surface_new_gl(info)
        if _skiaSurface != nil {
            _skiaCanvas = sk_surface_get_canvas(_skiaSurface)
        }
    }
    
    public var filename: String {
        get {
            return _filename
        }
        set {
            if newValue != _filename {
                _filename = newValue
                if flareActor != nil {
                    flareActor.dispose()
                    flareActor = nil
                    artboard = nil
                }
                
                if _filename.isEmpty || !_filename.hasSuffix(".flr") {
                    setNeedsDisplay()
                    return
                }
                
                let fActor = FlareSkActor()
                if fActor.loadFromBundle(filename: _filename) {
                    flareActor = fActor
                    artboard = fActor.artboard
                    if let ab = artboard {
                        ab.initializeGraphics()
                        ab.overrideColor = self.colorArray
                        ab.advance(seconds: 0.0)
                        updateBounds()
                    }

                    updateAnimation(onlyWhenMissing: true)
                    setNeedsDisplay()
                }
            }
        }
    }
    
    public var color: CGColor? {
        get {
            return _color
        }
        set {
            if newValue != _color {
                _color = newValue
                if let ab = artboard {
                    ab.overrideColor = self.colorArray
                }
                setNeedsDisplay()
            }
        }
    }
    
    private var colorArray: [Float]? {
        get {
            guard
                let c = _color,
                let colorSpaceModel = c.colorSpace?.model,
                let components = c.components
                else {
                    return nil
            }
            
            let fComponents = components.map { Float($0) }
            
            switch colorSpaceModel {
            case .rgb:
                return [fComponents[0],
                        fComponents[1],
                        fComponents[2],
                        fComponents[3]]
            case .monochrome:
                return [fComponents[0],
                        fComponents[0],
                        fComponents[0],
                        fComponents[1]]
            default:
                return nil
            }
        }
    }
    
    private func updateBounds() {
        guard let actor = flareActor else {
            return
        }
        
        setupAABB = actor.artboard?.artboardAABB()
    }

    private func updateAnimation(onlyWhenMissing: Bool = false) {
        //        if let aName = animationName, let ab = artboard {
        //            if let a = ab.getAnimation(name: aName) {
        if let ab = artboard {
            if let a = ab.animations?.first {
                self.animation = a
                a.apply(time: 0.0, artboard: ab, mix: 1.0)
                ab.advance(seconds: 0.0)
            }
            updatePlayState()
        }
    }
    
    private func updatePlayState() {
        if isPlaying && !isHidden {
            if displayLink == nil {
                displayLink = CADisplayLink(target: self, selector: #selector(beginFrame))
                lastTime = CACurrentMediaTime()
                displayLink!.add(to: .current, forMode: .common)
            }
        } else {
            if let dl = displayLink {
                dl.invalidate()
                displayLink = nil
            }
            lastTime = 0.0
        }
    }
    
    @objc private func beginFrame() {
        guard flareActor != nil else {
            updatePlayState()
            return
        }
        
        if let animation = self.animation, let artboard = self.artboard {
            /*
            let currentTime = CACurrentMediaTime()
            let delta = currentTime - lastTime
            lastTime = currentTime
            duration = (duration + delta)
            if animation.isLooping {
                duration = duration.truncatingRemainder(dividingBy: animation.duration)
            }
            animation.apply(time: duration, artboard: artboard, mix: 1.0)
            artboard.advance(seconds: delta)
            */
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
            skiaDraw(_skiaCanvas)
            glBindRenderbuffer(GLenum(GL_RENDERBUFFER), _colorRenderBuffer)
            _context!.presentRenderbuffer(Int(GL_RENDERBUFFER))
        }
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
