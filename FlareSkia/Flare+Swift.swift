//
//  Flare+Swift.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 11/7/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

extension UIColor {
    /// Extracts the rgb components of a `UIColor` as a `[Float]`.
    /// Each extracted component is a value between `0.0` and `1.0`.
    func rgb() -> [Float]? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return [Float(red), Float(green), Float(blue), Float(alpha)]
        }
        return nil
    }
}
