//
//  flare_sk_shape_with_transformed_stroke.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 11/3/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import Skia

class FlareSkShapeWithTransformedStroke: FlareSkShape {
    private var localPath: OpaquePointer!
    private var isLocalValid = false
    
    override func initializeGraphics() {
        super.initializeGraphics()
        localPath = sk_path_new()
    }
    
    override func invalidateShape() {
        isLocalValid = false
        super.invalidateShape()
    }
    
    func getLocalPath() -> OpaquePointer {
        if isLocalValid {
            return localPath
        }
        
        isLocalValid = true
        sk_path_reset(localPath)
        
        let inverseWorld = Mat2D()
        if !Mat2D.invert(inverseWorld, worldTransform) {
            Mat2D.identity(inverseWorld)
        }
        
        for path in paths {
            let skPath = (path as! FlareSkPath).path
            if let transform = path.pathTransform {
                let localTransform = Mat2D()
                Mat2D.multiply(localTransform, inverseWorld, transform)
                var skMat = sk_matrix_t(
                    mat: (
                        localTransform[0],
                        localTransform[2],
                        localTransform[4],
                        localTransform[1],
                        localTransform[3],
                        localTransform[5],
                        0, 0, 1.0
                    )
                )
                let matPointer = withUnsafeMutablePointer(to: &skMat) {
                    UnsafeMutablePointer($0)
                }
                sk_path_add_path_with_matrix(localPath, skPath, 0, 0, matPointer)
            } else {
                sk_path_add_path(localPath, skPath, 0, 0)
            }
        }
        
        return localPath
    }
    
    override func getRenderPath(_ skCanvas: OpaquePointer) -> OpaquePointer {
        var skMat = sk_matrix_t(
            mat: (
                worldTransform[0],
                worldTransform[2],
                worldTransform[4],
                worldTransform[1],
                worldTransform[3],
                worldTransform[5],
                0, 0, 1
            )
        )
        let matPointer = withUnsafePointer(to: &skMat) {
            UnsafePointer($0)
        }
        sk_canvas_concat(skCanvas, matPointer)
        
        return localPath
    }
}
