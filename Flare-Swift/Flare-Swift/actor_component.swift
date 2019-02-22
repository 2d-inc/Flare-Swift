//
//  actor_component.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/13/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

// Base abstract class
class ActorComponent: Equatable, Hashable {
    
    // Hashable Protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
    
    static func == (lhs: ActorComponent, rhs: ActorComponent) -> Bool {
        // Same reference
        return lhs === rhs
//        return lhs.parent == rhs.parent &&
//            lhs._parentIdx == rhs._parentIdx &&
//            lhs.name == rhs.name &&
//            lhs.idx == rhs.idx &&
//            lhs.dependents == rhs.dependents
    }
    
    init () {
        _name = "Unnamed"
        artboard = nil
    }
    convenience init(withArtboard ab: ActorArtboard) {
        self.init()
        self.artboard = ab
    }
    
    private var _name: String
    var name : String {
        get { return self._name }
    }
    
    var parent : ActorNode?
    var artboard : ActorArtboard?
    private var _parentIdx = 0
    var idx = 0
    var graphOrder = 0
    var dirtMask = ActorFlags.IsClean
    var dependents: [ActorComponent]?
    
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
    
    class func read(_ artboard: ActorArtboard, _ reader: StreamReader, _ component: ActorComponent) -> ActorComponent {
        component.artboard = artboard;
        component._name = reader.readString(label: "name");
        component._parentIdx = reader.readId(label: "parent");
    
        return component;
    }
    
    func copyComponent(_ component: ActorComponent, _ resetArtboard: ActorArtboard) {
        _name = component._name;
        artboard = resetArtboard;
        _parentIdx = component._parentIdx;
        idx = component.idx;
    }
}
