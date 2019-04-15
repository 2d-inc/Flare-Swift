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
    /// _path is of type `sk_path_t*` (i.e. C-style pointer)
    var _path: OpaquePointer { get set }
    var _isValid: Bool { get set }
    var isClosed: Bool { get }
    /// This getter relies (but not necessarily) on the getter implemented in `ActorBasePath`.
    var pathPoints: [PathPoint] { get }
}

extension FlareSkPath {
    var path: OpaquePointer {
        if _isValid {
            return _path
        }
        return self.makePath()
    }
    
    func makePath()  -> OpaquePointer {
        _isValid = true
        
        sk_path_reset(_path)
        
        let renderPoints = pathPoints
        guard !renderPoints.isEmpty else {
            return self._path
        }
        
        let firstPoint = renderPoints.first!
        sk_path_move_to(_path, firstPoint.translation[0], firstPoint.translation[1])
        
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
