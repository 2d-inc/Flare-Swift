//
//  path_point.swift
//  FlareCore
//
//  Created by Umberto Sonnino on 2/18/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public enum PointType: Int {
    case Straight = 0, Mirror, Disconnected, Asymmetric
}

public protocol PathPoint: class {
    var type: PointType { get set }
    var translation: Vec2D { get }
    var weights: [Float32]? { get set }
    
    init(ofType: PointType)
    
    func makeInstance() -> PathPoint
    func copy(from: PathPoint)
    func read(reader: StreamReader, isConnectedToBones: Bool)
    func readPoint(reader: StreamReader, isConnectedToBones: Bool)
    func transformed(transform: Mat2D) -> PathPoint
    func skin(world: Mat2D, bones: [Float32]) -> PathPoint?
}

public extension PathPoint {
    func copy(from: PathPoint) {
        self.type = from.type
        Vec2D.copy(self.translation, from.translation)
        if let w = from.weights {
            self.weights = w
        }
    }
    
    func read(reader: StreamReader, isConnectedToBones: Bool) {
        reader.readFloat32ArrayOffset(ar: &translation.values, length: 2, offset: 0, label: "translation")
        readPoint(reader: reader, isConnectedToBones: isConnectedToBones)
        if weights != nil {
            reader.readFloat32Array(ar: &weights!, label: "weights")
        }
    }
    
    func transformed(transform: Mat2D) -> PathPoint {
        let result = makeInstance()
        _ = Vec2D.transformMat2D(result.translation, result.translation, transform)
        return result
    }
}

public class StraightPathPoint: PathPoint {
    
    public var type: PointType
    public var translation = Vec2D()
    public var weights: [Float32]?
    var radius = 0.0
    
    required public init(ofType: PointType = .Straight) {
        type = ofType
    }
    
    convenience init(fromTranslation t: Vec2D) {
        self.init()
        self.translation = t
    }
    
    convenience init(fromValues t: Vec2D, _ r: Double) {
        self.init()
        self.translation = t
        self.radius = r
    }
    
    public func makeInstance() -> PathPoint {
        let node = StraightPathPoint()
        node.copyStraight(from: self)
        return node
    }
    
    private func copyStraight(from: StraightPathPoint) {
        copy(from: from)
        radius = from.radius
    }
    
    public func readPoint(reader: StreamReader, isConnectedToBones: Bool) {
        radius = Double(reader.readFloat32(label: "radius"))
        if isConnectedToBones {
            weights = Array<Float32>(repeating: 0.0, count: 8)
        }
    }
    
    public func skin(world: Mat2D, bones: [Float32]) -> PathPoint? {
        guard let w = weights else {
            print("StraightPathPoint::skin() - NO WEIGHTS?")
            return nil
        }
        let point = StraightPathPoint()
        point.radius = self.radius
        
        let px = world[0] * translation[0] + world[2] * translation[1] + world[4]
        let py = world[1] * translation[0] + world[3] * translation[1] + world[5]
        
        var a: Float32 = 0.0,
            b: Float32 = 0.0,
            c: Float32 = 0.0,
            d: Float32 = 0.0,
            e: Float32 = 0.0,
            f: Float32 = 0.0
        
        for i in 0 ..< 4 {
            let boneIndex = floor(w[i])
            let weight = w[i + 4]
            if weight > 0 {
                let bb = Int(boneIndex * 6)
                
                a += bones[bb] * weight
                b += bones[bb + 1] * weight
                c += bones[bb + 2] * weight
                d += bones[bb + 3] * weight
                e += bones[bb + 4] * weight
                f += bones[bb + 5] * weight
            }
        }
        
        point.translation[0] = a * px + c * py + e;
        point.translation[1] = b * px + d * py + f;
        
        return point;
    }
}

public class CubicPathPoint: PathPoint {
    public var type: PointType
    public var translation = Vec2D()
    public var weights: [Float32]?
    
    var _in = Vec2D()
    var _out = Vec2D()
    
    public required init(ofType: PointType) {
        self.type = ofType
    }
    
    public convenience init(fromValues t: Vec2D, _ inPoint: Vec2D, _ outPoint: Vec2D) {
        self.init(ofType: .Disconnected)
        self.translation = t
        self._in = inPoint
        self._out = outPoint
    }
    
    var inPoint: Vec2D {
        return _in
    }
    
    var outPoint: Vec2D {
        return _out
    }
    
    public func makeInstance() -> PathPoint {
        let node = CubicPathPoint(ofType: self.type)
        node.copyCubic(from: self)
        return node
    }
    
    private func copyCubic(from: CubicPathPoint) {
        self.copy(from: from)
        Vec2D.copy(_in, from._in)
        Vec2D.copy(_out, from._out)
    }
    
    public func readPoint(reader: StreamReader, isConnectedToBones: Bool) {
        reader.readFloat32ArrayOffset(ar: &_in.values, length: 2, offset: 0, label: "in")
        reader.readFloat32ArrayOffset(ar: &_out.values, length: 2, offset: 0, label: "out")
        if isConnectedToBones {
            weights = Array<Float32>(repeating: 0.0, count: 24)
        }
    }
    
    public func skin(world: Mat2D, bones: [Float32]) -> PathPoint? {
        guard let w = weights else {
            print("StraightPathPoint::skin() - NO WEIGHTS?")
            return nil
        }
        
        let point = CubicPathPoint(ofType: type)
        
        var px = world[0] * translation[0] + world[2] * translation[1] + world[4]
        var py = world[1] * translation[0] + world[3] * translation[1] + world[5]
        
        do {
            var a: Float32 = 0.0, b: Float32 = 0.0, c: Float32 = 0.0, d: Float32 = 0.0, e: Float32 = 0.0, f: Float32 = 0.0
            
            for i in 0 ..< 4 {
                let boneIndex = floor(w[i])
                let weight = w[i + 4]
                if weight > 0 {
                    let bb = Int(boneIndex * 6)
                    
                    a += bones[bb] * weight
                    b += bones[bb + 1] * weight
                    c += bones[bb + 2] * weight
                    d += bones[bb + 3] * weight
                    e += bones[bb + 4] * weight
                    f += bones[bb + 5] * weight
                }
            }
            
            let pos = point.translation
            pos[0] = a * px + c * py + e
            pos[1] = b * px + d * py + f
        }
        
        do {
            var a: Float32 = 0.0, b: Float32 = 0.0, c: Float32 = 0.0, d: Float32 = 0.0, e: Float32 = 0.0, f: Float32 = 0.0
            px = world[0] * _in[0] + world[2] * _in[1] + world[4]
            py = world[1] * _in[0] + world[3] * _in[1] + world[5]
            
            for i in 8 ..< 12 {
                let boneIndex = floor(w[i])
                let weight = w[i + 4]
                if weight > 0 {
                    let bb = Int(boneIndex * 6)
                    
                    a += bones[bb] * weight
                    b += bones[bb + 1] * weight
                    c += bones[bb + 2] * weight
                    d += bones[bb + 3] * weight
                    e += bones[bb + 4] * weight
                    f += bones[bb + 5] * weight
                }
            }
            
            let pos = point.inPoint
            pos[0] = a * px + c * py + e
            pos[1] = b * px + d * py + f
        }
        
        do {
            var a: Float32 = 0.0, b: Float32 = 0.0, c: Float32 = 0.0, d: Float32 = 0.0, e: Float32 = 0.0, f: Float32 = 0.0
            px = world[0] * _out[0] + world[2] * _out[1] + world[4]
            py = world[1] * _out[0] + world[3] * _out[1] + world[5]
            
            for i in 16 ..< 20 {
                let boneIndex = floor(w[i])
                let weight = w[i + 4]
                
                if weight > 0 {
                    let bb = Int(boneIndex * 6)
                    
                    a += bones[bb] * weight
                    b += bones[bb + 1] * weight
                    c += bones[bb + 2] * weight
                    d += bones[bb + 3] * weight
                    e += bones[bb + 4] * weight
                    f += bones[bb + 5] * weight
                }
            }
            
            let pos = point.outPoint
            pos[0] = a * px + c * py + e
            pos[1] = b * px + d * py + f
        }
        
        return point
    }
    
    
}
