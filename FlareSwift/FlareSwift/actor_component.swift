//
//  actor_component.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/13/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

// Base abstract class
public class ActorComponent: Equatable, Hashable {
    
    // Hashable Protocol
    public func hash(into hasher: inout Hasher) {
        hasher.combine(idx)
        hasher.combine(_parentIdx)
        hasher.combine(name)
        hasher.combine(parent)
    }

    public static func == (lhs: ActorComponent, rhs: ActorComponent) -> Bool {
        // Same reference
//        return lhs === rhs
        return lhs.parent == rhs.parent &&
            lhs._parentIdx == rhs._parentIdx &&
            lhs.name == rhs.name &&
            lhs.idx == rhs.idx
    }
    
    public init () {
        _name = "Unnamed"
        artboard = nil
    }
    public convenience init(withArtboard ab: ActorArtboard) {
        self.init()
        self.artboard = ab
    }
    
    private var _name: String
    public var name : String {
        get { return self._name }
    }
    
    public var parent : ActorNode?
    public var artboard : ActorArtboard?
    private var _parentIdx = 0
    public var idx = 0
    public var graphOrder = 0
    public var dirtMask = ActorFlags.IsClean
    public var dependents: [ActorComponent]?
    
    func resolveComponentIndices(_ components: [ActorComponent?]) {
        if let node = components[_parentIdx] as? ActorNode {
            if self is ActorNode {
                node.addChild(self as! ActorNode)
            } else {
                parent = node
            }
            _ = artboard!.addDependency(self, node)
        }
    }
        
    func completeResolve() {
        preconditionFailure("This method must be overridden")
    }
    
    func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        preconditionFailure("This method must be overridden")
    }
    
    func onDirty(_ dirt: UInt8)  {
        preconditionFailure("This method must be overridden")
    }
    func update(dirt: UInt8) {
        preconditionFailure("This method must be overridden")
    }
    
    func readComponent(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.artboard = artboard
        self._name = reader.readString(label: "name")
        self._parentIdx = reader.readId(label: "parent")
    }
    
    func copyComponent(_ component: ActorComponent, _ resetArtboard: ActorArtboard) {
        _name = component._name;
        artboard = resetArtboard;
        _parentIdx = component._parentIdx;
        idx = component.idx;
    }
}
