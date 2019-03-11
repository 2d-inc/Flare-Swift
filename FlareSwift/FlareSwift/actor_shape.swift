//
//  actor_shape.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/19/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public class ActorShape: ActorNode , ActorDrawable {
    var _isHidden: Bool = false
    var _strokes = [ActorStroke]()
    var _fills = [ActorFill]()
    var _clipShapes = [[ActorShape]]()
    
    public var _drawOrder: Int = -1
    public var drawIndex: Int = -1
    
    public var clipShapes: [[ActorShape]] {
        return _clipShapes
    }
    
    public var fill: ActorFill? {
        return _fills.isEmpty ? nil : _fills.first
    }
    
    var stroke: ActorStroke? {
        return _strokes.isEmpty ? nil : _strokes.first
    }
    
    public var fills: [ActorFill] {
        return _fills
    }
    
    var strokes: [ActorStroke] {
        return _strokes
    }
    
    public var drawOrder: Int {
        get {
            return _drawOrder
        }
        set {
            if _drawOrder != newValue {
                _drawOrder = newValue
                artboard!.markDrawOrderDirty()
            }
        }
    }
    
    public var isHidden: Bool {
        return _isHidden
    }
    
    public var doesDraw: Bool {
        return !_isHidden && !self.renderCollapsed
    }
    
    override func update(dirt: UInt8) {
        super.update(dirt: dirt)
        invalidateShape()
    }
    
    func copyShape(_ shape: ActorShape, _ ab: ActorArtboard) {
        copyNode(shape, ab)
        self.drawOrder = shape.drawOrder
        self._isHidden = shape._isHidden
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let shape = ActorShape()
        shape.copyShape(self, resetArtboard)
        return shape
    }
    
    public func computeAABB() -> AABB {
        var aabb: AABB? = nil
        for clips in _clipShapes {
            for node in clips {
                let bounds = node.computeAABB()
                if aabb == nil {
                    aabb = bounds;
                } else {
                    if (bounds[0] < aabb![0]) {
                        aabb![0] = bounds[0];
                    }
                    if (bounds[1] < aabb![1]) {
                        aabb![1] = bounds[1];
                    }
                    if (bounds[2] > aabb![2]) {
                        aabb![2] = bounds[2];
                    }
                    if (bounds[3] > aabb![3]) {
                        aabb![3] = bounds[3];
                    }
                }
            }
        }
        if aabb != nil {
            return aabb!
        }
        
//        for (ActorNode node in children) {
        if let c = children {
            for node in c {
                if let path = node as? ActorBasePath {
                    
                    // This is the axis aligned bounding box in the space of the parent (this case our shape).
                    let pathAABB = path.getPathAABB()
                    
                    if aabb == nil {
                        aabb = pathAABB;
                    } else {
                        // Combine.
                        aabb![0] = min(aabb![0], pathAABB[0]);
                        aabb![1] = min(aabb![1], pathAABB[1]);
                        
                        aabb![2] = max(aabb![2], pathAABB[2]);
                        aabb![3] = max(aabb![3], pathAABB[3]);
                    }
                }
            }
        }
        
        var minX = Float32.greatestFiniteMagnitude;
        var minY = Float32.greatestFiniteMagnitude;
        var maxX = -Float32.greatestFiniteMagnitude;
        var maxY = -Float32.greatestFiniteMagnitude;
        
        if (aabb == nil) {
            return AABB.init(fromValues: minX, minY, maxX, maxY)
        }
        
        let world = worldTransform;
        
        var maxStroke: Float = 0.0;
        for stroke in _strokes {
            if stroke.width > maxStroke {
                maxStroke = stroke.width;
            }
        }
        let padStroke = maxStroke / 2.0;
        aabb![0] -= padStroke;
        aabb![2] += padStroke;
        aabb![1] -= padStroke;
        aabb![3] += padStroke;
        
        let points = [
            Vec2D.init(fromValues: aabb![0], aabb![1]),
            Vec2D.init(fromValues: aabb![2], aabb![1]),
            Vec2D.init(fromValues: aabb![2], aabb![3]),
            Vec2D.init(fromValues: aabb![0], aabb![3])
        ]
        
//        for (var i = 0; i < points.length; i++) {
        for i in 0 ..< points.count {
            let pt = points[i]
            let wp = Vec2D.transformMat2D(pt, pt, world)
            if (wp[0] < minX) {
                minX = wp[0];
            }
            if (wp[1] < minY) {
                minY = wp[1];
            }
            if (wp[0] > maxX) {
                maxX = wp[0];
            }
            if (wp[1] > maxY) {
                maxY = wp[1];
            }
        }
        return AABB.init(fromValues: minX, minY, maxX, maxY)
    }
    
    public func initializeGraphics() {
        for stroke in _strokes {
            stroke.initializeGraphics()
        }
        for fill in _fills {
            fill.initializeGraphics()
        }
    }
    
    func readShape(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readNode(artboard, reader)
        _isHidden = !reader.readBool(label: "isVisible")
        _ = reader.readUint8(label: "blendMode") // Necessary read to keep it aligned
        drawOrder = Int(reader.readUint16(label: "drawOrder"))
    }
    
    func addStroke(_ stroke: ActorStroke) {
        _strokes.append(stroke)
    }
    
    func addFill(_ fill: ActorFill) {
        _fills.append(fill)
    }
    
    override func completeResolve() {
        _clipShapes = [[ActorShape]]()
        let clippers = self.allClips
        for clips in clippers {
            var shapes = [ActorShape]()
            for clip in clips {
                _ = clip.node!.all {
                    (n: ActorNode) -> Bool in
                        if let shape = n as? ActorShape {
                            shapes.append(shape)
                        }
                        return true
                }
            }
            if shapes.count > 0 {
                _clipShapes.append(shapes)
            }
        }
    }
    
}
