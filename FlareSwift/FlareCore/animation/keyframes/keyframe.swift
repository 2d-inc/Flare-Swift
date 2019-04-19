//
//  keyframe.swift
//  FlareCore
//
//  Created by Umberto Sonnino on 2/14/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

enum InterpolationTypes {
    case Hold, Linear, Cubic
}

let interpolationTypesLookup = [
    0: InterpolationTypes.Hold,
    1: InterpolationTypes.Linear,
    2: InterpolationTypes.Cubic
]

protocol KeyFrame: class {
    var _time: Double { get set }
    func applyInterpolation(component: ActorComponent, time: Double, toFrame: KeyFrame, mix: Float)
    func apply(component: ActorComponent, mix: Float)
    func setNext(_ frame: KeyFrame)
    func read(_ reader: StreamReader) -> Bool
}

extension KeyFrame {
    func readTime(_ reader: StreamReader) -> Bool {
        self._time = reader.readFloat64(label: "time")
        return true
    }
}

protocol Interpolated: KeyFrame {
    var _interpolator: Interpolator? { get set }
}

extension Interpolated {
    func readInterpolation(_ reader: StreamReader) -> Bool {
        if !self.readTime(reader) {
            return false
        }
        let type = Int(reader.readUint8(label: "interpolatorType"))
        var actualType = interpolationTypesLookup[type]
        if actualType == nil {
            print("WRONG INTERPOLATION TYPE?? \(type)")
            actualType = InterpolationTypes.Linear
        }
        
        switch actualType {
        case .Hold?:
            _interpolator = HoldInterpolator.instance
            break
        case .Linear?:
            _interpolator = LinearInterpolator.instance
            break
        case .Cubic?:
            let cubicInterpolator = CubicInterpolator.instance
            if cubicInterpolator.read(reader) {
                self._interpolator = cubicInterpolator
            }
            break
        default:
            _interpolator = nil
            break
        }
        return true
    }
}
