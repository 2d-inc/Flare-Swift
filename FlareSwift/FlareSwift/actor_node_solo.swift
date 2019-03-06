//
//  actor_node_solo.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/20/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class ActorNodeSolo: ActorNode {
    var _activeChildIndex = 0
    
    var activeChildIndex: Int {
        get {
            return _activeChildIndex
        }
        set {
            if newValue != _activeChildIndex {
                setActiveChildIndex(newValue)
            }
        }
    }
    
    func setActiveChildIndex(_ idx: Int) {
        if self._children != nil {
            self._activeChildIndex = min(self._children!.count, max(0, idx))
            for i in 0 ..< self._children!.count {
                let child = self._children![i]
                let cv = i != (self._activeChildIndex - 1)
                child.collapsedVisibility = cv
            }
        }
    }
    
    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let soloInstance = ActorNodeSolo()
        soloInstance.copySolo(self, resetArtboard)
        return soloInstance
    }
    
    private func copySolo(_ node: ActorNodeSolo, _ ab: ActorArtboard) {
        copyNode(node, ab)
        self._activeChildIndex = node._activeChildIndex
    }
    
    func readSolo(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readNode(artboard, reader)
        self._activeChildIndex = Int(reader.readUint32(label: "activeChild"))
    }
    
    override func completeResolve() {
        super.completeResolve()
        self.setActiveChildIndex(self._activeChildIndex)
    }
    
}
