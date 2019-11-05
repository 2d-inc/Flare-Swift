//
//  flare_sk_drawable.swift
//  FlareSkia
//
//  Created by Umberto Sonnino on 3/19/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import Skia
import os.log

protocol FlareSkDrawable: class {
    var artboard: ActorArtboard? { get set }
    var clipShapes: [[ClipShape]] { get }
    var _blendMode: BlendMode { get set }
    
    func draw(_ skCanvas: OpaquePointer)
    func clip(_ skCanvas: OpaquePointer)
    func onBlendModeChanged(_ mode: BlendMode)
}

enum BlendMode: UInt32 {
    case Clear = 0,
    Src,
    Dst,
    SrcOver,
    DstOver,
    SrcIn,
    DstIn,
    SrcOut,
    DstOut,
    SrcATop,
    DstATop,
    Xor,
    Plus,
    Modulate,
    Screen,
    Overlay,
    Darken,
    Lighten,
    ColorDodge,
    ColorBurn,
    HardLight,
    SoftLight,
    Difference,
    Exclusion,
    Multiply,
    Hue,
    Saturation,
    Color,
    Luminosity
    
    var skType: sk_xfermode_mode_t {
        return sk_xfermode_mode_t(rawValue: rawValue)
    }
    
    static var count: UInt32 { return 29 }
}

extension FlareSkDrawable {
    var blendMode: BlendMode {
        get {
            return _blendMode
        }
        set {
            if _blendMode != newValue {
                _blendMode = newValue
                onBlendModeChanged(_blendMode)
            }
        }
    }
    
    var blendModeId: UInt32 {
        get {
            return _blendMode.rawValue
        }
        set {
            guard newValue >= 0 && newValue < BlendMode.count else { return }
            if _blendMode.rawValue != newValue {
                _blendMode = BlendMode.init(rawValue: newValue)!
            }
        }
    }
    
    func clip(_ skCanvas: OpaquePointer) {
        guard let artboard = artboard else {
            os_log("Cannot clip: no artboard for this drawable.", type: .debug)
            return
        }
        for clips in clipShapes {
            for clipShape in clips {
                let shape = clipShape.shape
                if(shape.renderCollapsed) {
                    continue
                }
                if(clipShape.intersect) {
                    let shapePath = (shape as! FlareSkPath).path
                    sk_canvas_clip_path(skCanvas, shapePath, true)
                } else {
                    var clipRect = sk_rect_t()
                    let w = artboard.width
                    let h = artboard.height
                    clipRect.left = artboard.origin[0] * w
                    clipRect.top = artboard.origin[1] * h
                    clipRect.right = clipRect.left + w
                    clipRect.bottom = clipRect.top + h
                    
                    if let fill = shape.fill,
                        fill.fillRule == .EvenOdd {
                        let clipPath = sk_path_new()!
                        sk_path_set_evenodd(clipPath, true)
                        // Direction at 0 means that the path is CW,
                        // and this is the default value used in Skia.
                        let direction = sk_path_direction_t(rawValue: 0)
                        sk_path_add_rect(clipPath, &clipRect, direction)
                        
                        for path in shape.paths {
                            // One single clip path with subtraction rect and all sub paths.
                            let subpath = (path as! FlareSkPath).path
                            if let mat = path.pathTransform {
                                var skMat = sk_matrix_t(
                                    mat: (
                                        mat[0],
                                        mat[2],
                                        mat[4],
                                        mat[1],
                                        mat[3],
                                        mat[5],
                                        0, 0, 1
                                    )
                                )
                                let matPointer = withUnsafeMutablePointer(to: &skMat){
                                    UnsafeMutablePointer($0)
                                }
                                sk_path_add_path_with_matrix(clipPath, subpath, 0, 0, matPointer)
                            } else {
                                sk_path_add_path(clipPath, subpath, 0, 0)
                            }
                            
                            sk_canvas_clip_path(skCanvas, clipPath, true)
                        }
                    } else {
                        // One clip path with rect per shape path.
                        for path in shape.paths {
                            
                            let clipPath = sk_path_new()!
                            sk_path_set_evenodd(clipPath, true)
                            // Direction at 0 means that the path is CW,
                            // and this is the default value used in Skia.
                            let direction = sk_path_direction_t(rawValue: 0)
                            sk_path_add_rect(clipPath, &clipRect, direction)
                            
                            let subpath = (path as! FlareSkPath).path
                            if let mat = path.pathTransform {
                                var skMat = sk_matrix_t(
                                    mat: (
                                        mat[0],
                                        mat[2],
                                        mat[4],
                                        mat[1],
                                        mat[3],
                                        mat[5],
                                        0, 0, 1
                                    )
                                )
                                let matPointer = withUnsafeMutablePointer(to: &skMat){
                                    UnsafeMutablePointer($0)
                                }
                                sk_path_add_path_with_matrix(clipPath, subpath, 0, 0, matPointer)
                            } else {
                                sk_path_add_path(clipPath, subpath, 0, 0)
                            }
                            
                            sk_canvas_clip_path(skCanvas, clipPath, true)
                        }
                    }
                }
            }
        }
    }
}
