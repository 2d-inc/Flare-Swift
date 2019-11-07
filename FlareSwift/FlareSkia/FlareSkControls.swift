//
//  FlareSkControls.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 11/7/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public class FlareSkControls: FlareSkViewController {
    
    internal let mixSeconds: Double = 0.1
    internal var controlLayers = [FlareAnimationLayer]()
    
    /// Triggered when animation `name` completes.
    func onCompleted(name: String) {}
    
    /// If not `nil`, play the animation with the given `name`.
    /// Custom `mix` or `mixSeconds` can be specified.
    public func play(name: String?, mix: Double = 1.0, mixSeconds: Double = 0.2) {
        _animationName = name
        
        guard
            let aName = _animationName,
            let fView = view as? FlareSkView,
            let artboard = fView.artboard
        else { return }
        
        if let animation = artboard.getAnimation(name: aName) {
            controlLayers.append(
                FlareAnimationLayer(
                    animation,
                    name: aName,
                    mix: mix,
                    mixSeconds: mixSeconds
                )
            )
        }
    }
    
    override func advanceControls(by elapsed: Double) -> Bool {
        guard
            let fView = view as? FlareSkView,
            let artboard = fView.artboard
        else { return false }

        var lastFullyMixed = -1
        var lastMix = 0.0
        
        var completed = [FlareAnimationLayer]()
        
        for i in 0..<controlLayers.count {
            let layer = controlLayers[i]
            layer.mix += elapsed
            layer.time += elapsed
            
            lastMix = mixSeconds == 0.0
                ? 1.0
                : min(1.0, layer.mix / mixSeconds)
            
            if layer.isLooping {
                layer.time = layer.time.truncatingRemainder(dividingBy: layer.duration)
            }
            
            layer.animation.apply(time: layer.time, artboard: artboard, mix: Float(lastMix))
            
            if lastMix == 1.0 {
                lastFullyMixed = i
            }
            
            if layer.time > layer.animation.duration {
                completed.append(layer)
            }
        }
        
        if lastFullyMixed != -1 {
            controlLayers.removeSubrange(0..<lastFullyMixed)
        }
        
        if
            animationName == nil,
            controlLayers.count == 1,
            lastMix == 1.0
        {
            controlLayers.remove(at: 0)
        }
        
        for completedAnimation in completed {
            controlLayers.removeAll { $0 === completedAnimation }
            onCompleted(name: completedAnimation.name)
        }
        
        return !controlLayers.isEmpty
    }
    
    override func setViewTransform(viewTransform: Mat2D) {}
}
