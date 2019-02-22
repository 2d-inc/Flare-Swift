//
//  actor_path.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/18/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

protocol ActorBasePath: class {
    var points: [PathPoint] { get }
    var parent: ActorNode? { get }
    var pathTransform: Mat2D? { get }
    var transform: Mat2D { get }
    var allClips: [[ActorClip]] { get }
    
    func invalidatePath()
}

extension ActorBasePath {
    var isPathInWorldSpace: Bool {
        return false
    }
    
    var deformedPoints: [PathPoint] {
        return points
    }
    
    func getPathOBB() -> AABB {
        var minX = Float32.greatestFiniteMagnitude
        var minY = Float32.greatestFiniteMagnitude
        var maxX = -Float32.greatestFiniteMagnitude
        var maxY = -Float32.greatestFiniteMagnitude
        
        let renderPoints: [PathPoint] = points
        for point in renderPoints {
            var t = point.translation
            var x = t[0]
            var y = t[1]
            if x < minX {
                minX = x
            }
            if y < minY {
                minY = y
            }
            if x > maxX {
                maxX = x
            }
            if y > maxY {
                maxY = y
            }
            
            if point is CubicPathPoint {
                let cpp = point as! CubicPathPoint
                t = cpp.inPoint
                x = t[0]
                y = t[1]
                if x < minX {
                    minX = x
                }
                if y < minY {
                    minY = y
                }
                if x > maxX {
                    maxX = x
                }
                if y > maxY {
                    maxY = y
                }
                
                t = cpp.outPoint
                x = t[0]
                y = t[1]
                if x < minX {
                    minX = x
                }
                if y < minY {
                    minY = y
                }
                if x > maxX {
                    maxX = x
                }
                if y > maxY {
                    maxY = y
                }
            }
        }
        
        return AABB.init(fromValues: minX, minY, maxX, maxY)
        
    }
    
    func getPathAABB() -> AABB {
        var minX = Float32.greatestFiniteMagnitude
        var minY = Float32.greatestFiniteMagnitude
        var maxX = -Float32.greatestFiniteMagnitude
        var maxY = -Float32.greatestFiniteMagnitude
        
        let obb = getPathOBB()
        
        let pts = [
            Vec2D.init(fromValues: obb[0], y: obb[1]),
            Vec2D.init(fromValues: obb[2], y: obb[1]),
            Vec2D.init(fromValues: obb[2], y: obb[3]),
            Vec2D.init(fromValues: obb[0], y: obb[3])
        ]
        
        var localTransform: Mat2D
        if isPathInWorldSpace {
            localTransform = Mat2D()
        } else {
            localTransform = transform
        }
        
        for p in pts {
            let wp: Vec2D = Vec2D.transformMat2D(p, p, localTransform)
            if wp[0] < minX {
                minX = wp[0]
            }
            if wp[1] < minY {
                minY = wp[1]
            }
            
            if wp[0] > maxX {
                maxX = wp[0]
            }
            if wp[1] > maxY {
                maxY = wp[1]
            }
        }
        
        return AABB.init(fromValues: minX, minY, maxX, maxY)
    }
    
    func markPathDirty() {
        invalidatePath()
        if parent is ActorShape {
            parent!.invalidateShape()
        }
    }
}


class ActorProceduralPath: ActorNode, ActorBasePath {
    var points: [PathPoint] {
        return []
    }

    var pathTransform: Mat2D? {
        return worldTransform
    }
    
    var _width: Double = 0.0
    var _height: Double = 0.0
    
    var width: Double {
        get {
            return _width
        }
        set {
            if newValue != _width {
                _width = newValue
                markPathDirty()
            }
        }
    }
    
    var height: Double {
        get {
            return _height
        }
        set {
            if newValue != _height {
                _height = newValue
                markPathDirty()
            }
        }
    }
    
    override init() {}
    
    func invalidatePath() {
        preconditionFailure("Invalidating an ActorProceduralPath!")
    }
    
    func copyPath(_ node: ActorBasePath, _ resetArtboard: ActorArtboard) {
        guard let nodePath = node as? ActorProceduralPath else {
            fatalError("Copying nodePath that is not an ActorProceduralPath!")
        }
        
        copyNode(nodePath, resetArtboard)
        _width = nodePath.width
        _height = nodePath.height
    }
    
    override func onDirty(_ dirt: UInt8) {
        super.onDirty(dirt)
        // We transformed, make sure parent is invalidated.
        if parent is ActorShape {
            parent?.invalidateShape()
        }
    }
}

class ActorPath: ActorSkinnable, ActorBasePath {
    var _isHidden: Bool = false
    var _isClosed: Bool = false
    var _points: [PathPoint] = []
    var vertexDeform: [Float32]?
    var skin: ActorSkin?
    let VertexDeformDirty: UInt8 = 1 << 1
    
    var points: [PathPoint] {
        return _points
    }
    
    var pathTransform: Mat2D? {
        return self.isConnectedToBones ? nil : worldTransform
    }
    
    var isPathInWorldSpace: Bool {
        return self.isConnectedToBones
    }
    
    var deformedPoints: [PathPoint] {
        if !isConnectedToBones || skin == nil {
            return _points
        }
        
        let boneMatrices = skin!.boneMatrices
        var deformed = [PathPoint]()
        for point in _points {
            deformed.append(point.skin(world: worldTransform, bones: boneMatrices!)!)
        }
        return deformed
    }
    
    override init() {
        
    }
    
    override func onDirty(_ dirt: UInt8) {
        super.onDirty(dirt)
        if parent is ActorShape {
            parent?.invalidateShape()
        }
    }
    
    func makeVertexDeform() {
        if vertexDeform != nil {
            print("ActorPath::makeVertexDeform() - VERTEX DEFORM ALREADY SPECIFIED!")
            return
        }
        var length = 0
        for point in points {
            length += 2 + ((point.type == .Straight) ? 1 : 4)
        }
        
        var vertices = Array<Float32>.init(repeating: 0, count: length)
        var readIdx = 0
        for point in points {
            vertices[readIdx] = point.translation[0]
            readIdx += 1
            vertices[readIdx] = point.translation[1]
            readIdx += 1
            if point.type == .Straight {
                // radius
                vertices[readIdx] = Float32((point as! StraightPathPoint).radius)
                readIdx += 1
            } else {
                // in/out
                let cubicPoint = point as! CubicPathPoint
                vertices[readIdx] = cubicPoint.inPoint[0]
                readIdx += 1
                vertices[readIdx] = cubicPoint.inPoint[1]
                readIdx += 1
                vertices[readIdx] = cubicPoint.outPoint[0]
                readIdx += 1
                vertices[readIdx] = cubicPoint.outPoint[1]
                readIdx += 1
            }
        }
        vertexDeform = vertices;
    }
    
    func invalidatePath() {
        // Up to the implementation.
    }
    
    func markVertexDeformDirty() {
        if artboard != nil {
            _ = artboard?.addDirt(self, value: VertexDeformDirty, recurse: false)
        }
    }
    
    override func update(dirt: UInt8) {
        if vertexDeform != nil && (dirt & VertexDeformDirty) == VertexDeformDirty {
            var readIdx = 0
            for point in _points {
                point.translation[0] = vertexDeform![readIdx]
                readIdx += 1
                point.translation[1] = vertexDeform![readIdx]
                readIdx += 1
                switch (point.type) {
                case PointType.Straight:
                    (point as! StraightPathPoint).radius = Double(vertexDeform![readIdx])
                    readIdx += 1
                    break;
                    
                default:
                    let cubicPoint = point as! CubicPathPoint;
                    cubicPoint.inPoint[0] = vertexDeform![readIdx]
                    readIdx += 1
                    cubicPoint.inPoint[1] = vertexDeform![readIdx]
                    readIdx += 1
                    cubicPoint.outPoint[0] = vertexDeform![readIdx]
                    readIdx += 1
                    cubicPoint.outPoint[1] = vertexDeform![readIdx]
                    readIdx += 1
                    break
                }
            }
        }
        markPathDirty()
        
        super.update(dirt: dirt)
    }
    
    static func read(_ artboard: ActorArtboard, _ reader: StreamReader, _ component: inout ActorPath?) -> ActorPath {
        if component == nil {
            component = ActorPath()
        }
        
        _ = ActorSkinnable.read(artboard, reader, component!)
        
        component!._isHidden = !reader.readBool(label: "isVisible")
        component!._isClosed = reader.readBool(label: "isClosed")
        
        reader.openArray(label: "points")
        let pointCount = Int(reader.readUint16Length())
        component!._points = Array<PathPoint>()
        
        for i in 0 ..< pointCount {
            reader.openObject(label: "point")
            var point: PathPoint?
            let type: PointType = PointType(rawValue: Int(reader.readUint8(label: "pointType")))!
            switch type {
            case PointType.Straight:
                point = StraightPathPoint()
                break
            default:
                point = CubicPathPoint(ofType: type)
                break
            }
            if point == nil {
                fatalError("Invalid point type: \(type)")
            } else {
                point!.read(reader: reader, isConnectedToBones: component!.isConnectedToBones)
            }
            reader.closeObject()
            
            component!._points[i] = point!
        }
        reader.closeArray();
        return component!
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instancePath = ActorPath()
        instancePath.copyPath(self, resetArtboard)
        return instancePath
    }
    
    func copyPath(_ node: ActorBasePath, _ resetArtboard: ActorArtboard) {
        let nodePath = node as! ActorPath
        copySkinnable(nodePath, resetArtboard)
        _isHidden = nodePath._isHidden
        _isClosed = nodePath._isClosed
        
        let pointCount = nodePath._points.count
        
        _points = [PathPoint]()
        for i in 0 ..< pointCount {
            _points.insert(nodePath._points[i].makeInstance(), at: i)
        }
        
        if let vd = nodePath.vertexDeform {
            vertexDeform = vd // TODO: Test copy b/c Array is a value type?
        }
    }
    
}
