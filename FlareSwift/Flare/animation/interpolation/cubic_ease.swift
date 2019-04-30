//
//  cubic_ease.swift
//  Flare
//
//  Created by Umberto Sonnino on 2/18/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

// Implements https://github.com/gre/bezier-easing/blob/master/src/index.js
let NewtonIterations = 4
let NewtonMinSlope: Float = 0.001
let SubdivisionPrecision: Float = 0.0000001
let SubdivisionMaxIterations = 10

let SplineTableSize = 11
let SampleStepSize = 1.0 / (Float(SplineTableSize) - 1.0)

// Returns x(t) given t, x1, and x2, or y(t) given t, y1, and y2.
func calcBezier(_ aT: Float, _ aA1: Float, _ aA2: Float) -> Float {
    return (((1.0 - 3.0 * aA2 + 3.0 * aA1) * aT + (3.0 * aA2 - 6.0 * aA1)) * aT + (3.0 * aA1)) * aT
}

// Returns dx/dt given t, x1, and x2, or dy/dt given t, y1, and y2.
func getSlope(_ aT: Float, _ aA1: Float, _ aA2: Float) -> Float {
    return 3.0 * (1.0 - 3.0 * aA2 + 3.0 * aA1) * aT * aT + 2.0 * (3.0 * aA2 - 6.0 * aA1) * aT + (3.0 * aA1)
}

func newtonRaphsonIterate(_ aX: Float, _ aGuessT: inout Float, _ mX1: Float, _ mX2: Float) -> Float {
    for _ in 0 ..< NewtonIterations {
        let currentSlope = getSlope(aGuessT, mX1, mX2)
        if (currentSlope == 0.0) {
            return aGuessT
        }
        let currentX = calcBezier(aGuessT, mX1, mX2) - aX
        aGuessT -= currentX / currentSlope
    }
    return aGuessT
}

protocol CubicEase: class {
    func ease(t: Float) -> Float
}

class EaseFactory {
    static func make(x1: Float, y1: Float, x2: Float, y2: Float) -> CubicEase {
        if x1 == y1 && x2 == y2 {
            return LinearCubicEase()
        } else {
            return Cubic(x1: x1, y1: y1, x2: x2, y2: y2)
        }
    }
}

class LinearCubicEase: CubicEase {
    func ease(t: Float) -> Float {
        return t
    }
}

class Cubic: CubicEase {
    private var _values: [Float]
    let x1, x2, y1, y2: Float
    
    init(x1: Float, y1: Float, x2: Float, y2: Float) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        _values = [Float]()
        for i in 0 ..< SplineTableSize {
            _values.insert(calcBezier(Float(i) * SampleStepSize, x1, x2), at: i)
        }
    }
    
    func getT(_ x: Float) -> Float {
        var intervalStart: Float = 0.0
        var currentSample = 1
        let lastSample = SplineTableSize - 1
        
        while currentSample != lastSample && _values[currentSample] <= x {
            intervalStart += SampleStepSize
            currentSample += 1
        }
        currentSample -= 1
        
        // Interpolate to provide an initial guess for t
        let dist = (x - _values[currentSample]) / (_values[currentSample + 1] - _values[currentSample])
        var guessForT = intervalStart + dist * SampleStepSize
        
        let initialSlope = getSlope(guessForT, x1, x2)
        if initialSlope >= NewtonMinSlope {
            for _ in 0 ..< NewtonIterations {
                let currentSlope = getSlope(guessForT, x1, x2)
                if (currentSlope == 0.0) {
                    return guessForT
                }
                let currentX = calcBezier(guessForT, x1, x2) - x
                guessForT -= currentX / currentSlope
            }
            return guessForT
        } else if (initialSlope == 0.0) {
            return guessForT
        } else {
            var aB = intervalStart + SampleStepSize
            var currentX, currentT: Float
            var i = -1
            repeat {
                i += 1
                currentT = intervalStart + (aB - intervalStart) / 2.0
                currentX = calcBezier(currentT, x1, x2) - x
                if (currentX > 0.0) {
                    aB = currentT
                } else {
                    intervalStart = currentT
                }
            } while (abs(currentX) > SubdivisionPrecision &&
                i < SubdivisionMaxIterations)
            return currentT
        }
    }
    
    func ease(t: Float) -> Float {
        return calcBezier(getT(t), y1, y2)
    }
}
