//
//  custom_property.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 11/13/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

extension Optional {
    func wrappedType() -> Any.Type {
        return Wrapped.self
    }
}

class CustomProperty<T> : ActorComponent {
    internal var value: T?

    override func makeInstance(_ resetArtboard: ActorArtboard) -> ActorComponent {
        let instance = CustomProperty<T>()
        instance.copyComponent(self, resetArtboard)
        instance.value = self.value
        return instance
    }
    
    override func completeResolve() {}
    override func onDirty(_ dirt: UInt8) {}
    override func update(dirt: UInt8) {}
    
    func readCustomProperty(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readComponent(artboard, reader)
        let propertyType = value.wrappedType()
        switch propertyType {
        case is Float.Type:
            self.value = (reader.readFloat32(label: "float") as! T)
        case is Int.Type:
            self.value = (reader.readInt32(label: "int") as! T)
        case is String.Type:
            self.value = (reader.readString(label: "string") as! T)
        case is Bool.Type:
            self.value = (reader.readBool(label: "bool") as! T)
        default:
            fatalError("Custom Properties of type \(type(of: value)) are not supported!")
        }
    }
    
    override func resolveComponentIndices(_ components: [ActorComponent?]) {
        super.resolveComponentIndices(components)
        
        if self.parentIdx >= 0 {
            if let parent = components[self.parentIdx] {
                parent.addCustomProperty(self)
            }
        }
    }
}
