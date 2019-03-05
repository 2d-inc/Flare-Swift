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
    var _fillRule: FillRule { get set }
    var _fillColor: CGColor { get set }
    func initializeGraphics()
    func paint(fill: ActorFill, context: CGContext, path: CGPath)
}

extension FlareFill {
    var cgFillRule: CGPathFillRule {
        switch _fillRule {
        case .EvenOdd:
            return .evenOdd
        case .NonZero:
            return .winding
        }
    }
}
