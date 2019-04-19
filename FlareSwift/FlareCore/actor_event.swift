//
//  actor_event.swift
//  FlareCore
//
//  Created by Umberto Sonnino on 2/15/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public class ActorEvent: ActorComponent {
    
    func readEvent(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readComponent(artboard, reader)
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
