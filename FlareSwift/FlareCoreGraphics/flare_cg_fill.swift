//
//  flare_cg_fill.swift
//  FlareCoreGraphics
//
//  Created by Umberto Sonnino on 2/26/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

protocol FlareCGFill: class {
    var _fillRule: FillRule { get set }
    var _fillColor: CGColor { get set }
    func initializeGraphics()
    func paint(fill: ActorFill, on: CALayer, path: CGPath)
}

extension FlareCGFill {
    var fillRule: CAShapeLayerFillRule {
        switch _fillRule {
        case .EvenOdd:
            return .evenOdd
        case .NonZero:
            return .nonZero
        }
    }
}
