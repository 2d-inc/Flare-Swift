//
//  flare_sk_path.swift
//  FlareSkia
//
//  Created by Umberto Sonnino on 2/22/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import Skia

protocol FlareSkPath: class {
    var path: OpaquePointer { get }
    func initializeGraphics()
}

protocol FlareSkPathPointsPath: FlareSkPath {
    /// _path is of type `sk_path_t*` (i.e. C-style pointer)
    var _path: OpaquePointer { get set }
    var _isValid: Bool { get set }
    var isClosed: Bool { get }
    var deformedPoints: [PathPoint] { get }
    
    func invalidatePath()
    func getPathPoints() -> [PathPoint]
    func makePath()  -> OpaquePointer
}

extension FlareSkPathPointsPath {
    var path: OpaquePointer {
        if _isValid {
            return _path
        }
        return self.makePath()
    }
    
    func initializeGraphics() {
        _path = sk_path_new()
    }
    
    func invalidatePath() {
        _isValid = false
    }
    
    func getPathPoints() -> [PathPoint] {
        let pts = deformedPoints
        guard !pts.isEmpty else {
            return []
        }
        
        var pathPoints = [PathPoint]()
        let pc = pts.count
        
        let arcConstant: Float32 = 0.55
        let iarcConstant = 1.0 - arcConstant
        var previous = isClosed ? pts.last : nil
        
        for i in 0 ..< pc {
            let point = pts[i]
            switch point.type {
            case .Straight:
                let straightPoint = point as! StraightPathPoint
                let radius = straightPoint.radius
                if radius > 0 {
                    if !isClosed && (i == 0 || i == pc - 1) {
                        pathPoints.append(point)
                        previous = point
                    } else {
                        let next = pts[(i+1)%pc]
                        let prevPoint = previous is CubicPathPoint ? (previous as! CubicPathPoint).outPoint : previous!.translation
                        let nextPoint = next is CubicPathPoint ? (next as! CubicPathPoint).inPoint : next.translation
                        let pos = point.translation
                        
                        let toPrev = Vec2D.subtract(Vec2D(), prevPoint, pos)
                        let toPrevLength = Vec2D.length(toPrev)
                        toPrev[0] /= toPrevLength
                        toPrev[1] /= toPrevLength
                        
                        let toNext = Vec2D.subtract(Vec2D(), nextPoint, pos)
                        let toNextLength = Vec2D.length(toNext)
                        toNext[0] /= toNextLength
                        toNext[1] /= toNextLength
                        
                        let renderRadius = min(toPrevLength, min(toNextLength, Float32(radius)))
                        var translation = Vec2D.scaleAndAdd(Vec2D(), pos, toPrev, renderRadius)
                        pathPoints.append(CubicPathPoint.init(fromValues: translation, translation, Vec2D.scaleAndAdd(Vec2D(), pos, toPrev, iarcConstant * renderRadius)))
                        
                        translation = Vec2D.scaleAndAdd(Vec2D(), pos, toNext, renderRadius)
                        previous = CubicPathPoint.init(fromValues: translation, Vec2D.scaleAndAdd(Vec2D(), pos, toNext, iarcConstant * renderRadius), translation)
                        pathPoints.append(previous!)
                    }
                } else {
                    pathPoints.append(point)
                    previous = point
                }
                break
            default:
                pathPoints.append(point)
                previous = point
                break
            }
        }
        
        return pathPoints
    }
    
    func makePath()  -> OpaquePointer {
        _isValid = true
        sk_path_reset(_path)
        
        let renderPoints = getPathPoints()
        guard !renderPoints.isEmpty else {
            return self._path
        }
        
        let firstPoint = renderPoints.first!
        sk_path_move_to(_path, firstPoint.translation[0], firstPoint.translation[1])
//        print("START FROM: \(firstPoint.translation.description)")
        
        let c = isClosed ? renderPoints.count : renderPoints.count - 1
        let rpc = renderPoints.count
        for i in 0 ..< c {
            let point = renderPoints[i]
            let nextPoint = renderPoints[(i+1)%rpc]
            var cin = nextPoint is CubicPathPoint ? (nextPoint as! CubicPathPoint).inPoint : nil
            var cout = point is CubicPathPoint ? (point as! CubicPathPoint).outPoint : nil
            if cin == nil && cout == nil {
//                print("LINE TO: \(nextPoint.translation.description)")
                sk_path_line_to(_path, nextPoint.translation[0], nextPoint.translation[1])
            } else {
                if cout == nil {
                    cout = point.translation
                }
                if cin == nil {
                    cin = nextPoint.translation
                }
                
//                print("CUBIC TO: \(nextPoint.translation.description), C1: \(cout!.description), C2: \(cin!.description)")
                sk_path_cubic_to(_path,
                                 cout![0], cout![1],
                                 cin![0], cin![1],
                                 nextPoint.translation[0], nextPoint.translation[1])
            }
        }
        
        if isClosed {
            sk_path_close(_path)
        }
        
        return _path
    }
}
