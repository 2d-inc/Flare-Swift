//
//  actor_drawable.swift
//  Flare
//
//  Created by Umberto Sonnino on 2/14/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public enum BlendModes {
    case Normal, Multiply, Screen, Additive
}

public class ClipShape {
    let shape: ActorShape
    let intersect: Bool
    init(_ s: ActorShape, _ i: Bool) {
        shape = s
        intersect = i
    }
}

/// This protocol requires that its implementation will be mixed together with an [ActorNode], or an
/// [ActorNode] descendant.
public protocol ActorDrawable: class {
    // Editor set draw index.
    var _drawOrder: Int { get set }
    // Computed draw index in the draw list.
    var drawIndex: Int { get set }
    var isHidden: Bool { get set }
    var blendModeId: UInt32 { get set }
    var _clipShapes: [[ClipShape]]? { get set }
    
    func computeAABB() -> AABB
    func initializeGraphics()
    
    // From ActorNode
    var artboard: ActorArtboard? { get }
    var renderCollapsed: Bool { get }
    var allClips: [[ActorClip]] { get }
    func readNode(_ artboard: ActorArtboard, _ reader: StreamReader)
    func copyNode(_ node: ActorNode, _ resetArtboard: ActorArtboard)
}

extension ActorDrawable {
    var drawOrder: Int {
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
    
    var clipShapes: [[ClipShape]] {
        return _clipShapes ?? []
    }
    
    var doesDraw: Bool {
        return !isHidden && !renderCollapsed
    }
    
    func readDrawable(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readNode(artboard, reader)
        
        self.isHidden = !reader.readBool(label: "isVisible")
        self.blendModeId = artboard.actor.version < 21 ? 3 : UInt32(reader.readUint8(label: "blendMode"))
        self.drawOrder = Int(reader.readUint16(label: "drawOrder"))
    }
    
    func copyDrawable(_ node: ActorDrawable, _ resetArtboard: ActorArtboard) {
        self.copyNode(node as! ActorNode, resetArtboard)
        drawOrder = node.drawOrder
        blendModeId = node.blendModeId
        isHidden = node.isHidden
    }
    
    func completeResolve() {
        _clipShapes = [[ClipShape]]()
        let clippers = allClips
        
        for clips in clippers {
            var shapes = [ClipShape]()
            for clip in clips {
                _ = clip.node?.all({ (node: ActorNode) -> Bool in
                    if let shapeNode = node as? ActorShape {
                        shapes.append(ClipShape(shapeNode, clip.intersect))
                    }
                    return true
                })
            }
            if !shapes.isEmpty {
                _clipShapes!.append(shapes)
            }
        }
    }
}
