//
//  dependency_sorter.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/13/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class DependencySorter {
    var _perm: Set<ActorComponent>
    var _temp: Set<ActorComponent>
    var _order: [ActorComponent]?
    
    init() {
        _perm = []
        _temp = []
    }
    
    func sort(_ root: ActorComponent) -> [ActorComponent]? {
        _order = [ActorComponent]()
        if (!visit(root)) {
            return nil
        }
        return _order
    }
    
    func visit(_ n: ActorComponent) -> Bool {
        if (_perm.contains(n)) {
            return true
        }
        if (_temp.contains(n)) {
            print("Dependency cycle!")
            return false
        }

        _temp.insert(n)
    
        if let dependents = n.dependents {
            for d in dependents {
                if !visit(d) {
                    return false
                }
            }
        }
        _perm.insert(n)
        _order?.insert(n, at: 0)
    
        return true
    }
}
