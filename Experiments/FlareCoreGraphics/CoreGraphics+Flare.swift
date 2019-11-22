//
//  CoreGraphics+Flare.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 2/28/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import CoreGraphics
#endif

/// Cross Platform Images.
/// Credit to: https://gist.github.com/JohnSundell/05f837a3f901630e65e3652945424ba5
#if os(macOS)
import Cocoa
typealias UIImage = NSImage
#endif

/// Helper class extension to integrate a static factory constructor for the two different SDKs
extension CGColor {
    #if os(iOS)
    static var black: CGColor = UIColor.black.cgColor
    static var white: CGColor = UIColor.white.cgColor
    static var clear: CGColor = UIColor.clear.cgColor
    static func cgColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> CGColor {
        return UIColor.init(red: red, green: green, blue: blue, alpha: alpha).cgColor
    }
    #elseif os(macOS)
    static func cgColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> CGColor {
        return CGColor(red: red, green: gree, blue: blue, alpha: alpha)
    }
    #endif
    
    static func toFloatArray(color: CGColor?) -> [Float]? {
        if let c = color {
            if let components = c.components {
                return [Float(components[0]),
                        Float(components[1]),
                        Float(components[2]),
                        Float(components[3])]
            }
        }
        return nil
    }
    
}

/// Additional functionality added to CGPath for debugging purposes.
/// Credit to: https://stackoverflow.com/a/36374209
extension CGPath {
    func forEach( body: @escaping @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
    }
    func getPathElementsPoints() -> [CGPoint] {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
            default: break
            }
        }
        return arrayPoints
    }
    func getPathElementsPointsAndTypes() -> ([CGPoint],[CGPathElementType]) {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        var arrayTypes : [CGPathElementType]! = [CGPathElementType]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            default: break
            }
        }
        return (arrayPoints,arrayTypes)
    }
}

/**
 Let CGMutablePath conform to the ConcretePath protocol.
 */
extension CGMutablePath: ConcretePath {
    func moveTo(_ to: Vec2D) {
        self.move(to: Vec2D.toCGPoint(to))
    }
    
    func lineTo(_ to: Vec2D) {
        self.addLine(to: Vec2D.toCGPoint(to))
    }
    
    func curveTo(_ to: Vec2D, control1: Vec2D, control2: Vec2D) {
        self.addCurve(to: Vec2D.toCGPoint(to),
                      control1: Vec2D.toCGPoint(control1),
                      control2: Vec2D.toCGPoint(control2)
        )
    }
    
    func addPath(_ subpath: ConcretePath, mat: Mat2D) {
        let transform = __CGAffineTransformMake(
            CGFloat(mat[0]),
            CGFloat(mat[1]),
            CGFloat(mat[2]),
            CGFloat(mat[3]),
            CGFloat(mat[4]),
            CGFloat(mat[5])
        )
        self.addPath(subpath as! CGMutablePath, transform: transform)
    }
}

extension CGPoint {
    init(x: Float32, y: Float32) {
        self.init()
        self.x = CGFloat(x)
        self.y = CGFloat(y)
    }
}
