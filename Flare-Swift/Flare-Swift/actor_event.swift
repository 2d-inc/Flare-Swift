//
//  actor_event.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/15/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class ActorEvent: ActorComponent {
    
    static func read(_ artboard: ActorArtboard, _ reader: StreamReader, _ component: inout ActorEvent) ->  ActorComponent {
        _ = ActorComponent.read(artboard, reader, component);
        
        return component
    }
    
    func makeInstance(resetArtboard: ActorArtboard) -> ActorComponent {
        let instanceEvent = ActorEvent();
        instanceEvent.copyComponent(self, resetArtboard);
        return instanceEvent;
    }
    
    override func completeResolve() {}
    override func onDirty(_ dirt: UInt8) {}
    override func update(dirt: UInt8) {}
}
