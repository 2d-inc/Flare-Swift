//
//  flare_cg_path.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/22/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

protocol FlareCGPath: class {
    var _path: CGMutablePath { get set }
    var path: CGMutablePath { get }
    var _isValid: Bool { get set }
    var isClosed: Bool { get }
    /// This getter relies (but not necessarily) on the getter implemented in `ActorBasePath`.
    var pathPoints: [PathPoint] { get }
}

extension FlareCGPath {
    var path: CGMutablePath {
        if _isValid {
            return _path
        }
        return self.makePath()
    }
    
    func makePath()  -> CGMutablePath {
        _isValid = true
        
        self._path = CGMutablePath() // reset.
        
        let renderPoints = pathPoints
        guard !renderPoints.isEmpty else {
            return self._path
        }
        
        let firstPoint = renderPoints.first!
        self._path.move(to: CGPoint(x: firstPoint.translation[0], y: firstPoint.translation[1]))
        
        let c = isClosed ? renderPoints.count : renderPoints.count - 1
        let rpc = renderPoints.count
        for i in 0 ..< c {
            let point = renderPoints[i]
            let nextPoint = renderPoints[(i+1)%rpc]
            var cin = nextPoint is CubicPathPoint ? (nextPoint as! CubicPathPoint).inPoint : nil
            var cout = point is CubicPathPoint ? (point as! CubicPathPoint).outPoint : nil
            if cin == nil && cout == nil {
                let x = Double(nextPoint.translation[0])
                let y = Double(nextPoint.translation[1])
//                print("ADDING LINE: (x \(x), y \(y))")
                _path.addLine(to: CGPoint(x: x, y: y))
            } else {
                if cout == nil {
                    cout = point.translation
                }
                if cin == nil {
                    cin = nextPoint.translation
                }
                let CGTo = CGPoint(x: nextPoint.translation[0], y: nextPoint.translation[1])
                let CGCin = CGPoint(x: cin![0], y: cin![1])
                let CGCout = CGPoint(x: cout![0], y: cout![1])
//                print("ADDING CURVE: (To \(CGTo), Cout \(CGCout), Cin \(CGCin))")
                _path.addCurve(to: CGTo, control1: CGCout, control2: CGCin)
            }
        }
        
        if isClosed {
            _path.closeSubpath()
        }
        
        return _path
    }
}
