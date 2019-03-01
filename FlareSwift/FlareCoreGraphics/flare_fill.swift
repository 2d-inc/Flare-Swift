//
//  flare_fill.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import CoreGraphics

protocol FlareFill: class {
    var _paint: CGColor { get set }
    func initializeGraphics()
    func paint(fill: ActorFill, context: CGContext, path: CGPath)
}

extension FlareFill {
    
    func initializeGraphics() {
        _paint = CGColor.black
    }
    
    func paint(fill: ActorFill, context: CGContext, path: CGPath) {
        var pathFillRule: CGPathFillRule
        switch fill.fillRule {
        case .EvenOdd:
            pathFillRule = .evenOdd
            break
        case .NonZero:
            pathFillRule = .winding
            break
        }
        context.saveGState()
        context.setFillColor(_paint)
        context.addPath(path)
        context.fillPath(using: pathFillRule)
        context.restoreGState()
    }
}
