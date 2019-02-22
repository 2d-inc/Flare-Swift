//
//  flare_path.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/22/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import CoreGraphics

protocol FlarePath {
    var _path: CGPath { get set }
    var path: CGPath { get }
    var _isValid: Bool { get }
    
    func makePath() -> CGPath
}

extension FlarePath {
    var path: CGPath {
        if _isValid {
            return _path
        }
        return _makePath()
    }
    
    func makePath() {
        _isValid = true
        _path.
    }
}
