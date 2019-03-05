//
//  flare_color.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 2/28/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

// Helper class to integrate a static factory constructor for the two different SDKs

extension CGColor {
    #if os(iOS)
    static var black: CGColor = UIColor.black.cgColor
    static var white: CGColor = UIColor.white.cgColor
    static var clear: CGColor = UIColor.clear.cgColor
    static func cgColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> CGColor {
        return UIColor.init(red: red, green: green, blue: blue, alpha: alpha).cgColor
    }
    #elseif os(OSX)
    static func cgColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> CGColor {
        return CGColor(red: red, green: gree, blue: blue, alpha: alpha)
    }
    #endif
    
}
