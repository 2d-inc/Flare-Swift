//
//  CustomController.swift
//  BasicExample
//
//  Created by Mandy Lowry on 11/11/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import FlareSwift

class CustomController: FlareSkViewController {
    
    internal let mixSeconds: Double = 0.1
    internal var controlLayers = [FlareAnimationLayer]()
    
    var animation: ActorAnimation? = nil
    
    var animTime: Double = 0.00;
    var currentAnimTime: Double  = 0;
    
    override open var isPlaying: Bool {
        return !isPaused &&
            (!controlLayers.isEmpty || super.isPlaying)
    }
    
    open func onCompleted(name: String) {
        if(name == "Mustache_New"){
            play(name: "Idle")
        }
    }
    
    public func play(name: String?, mix: Double = 1.0, mixSeconds: Double = 0.2) {
        animationName = name
        guard
            let aName = animationName,
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
            updatePlayState()
        }
    }
    
    override open func advanceControls(by elapsed: Double) -> Bool {
        
        guard
            let fView = view as? FlareSkView,
            let artboard = fView.artboard
            else { return false }
        
        /** CustomProperties:
         let myNode = artboard.getNode(name: "Scale Node_Special Property")
         for cpNodes in myNode.CustomProperties {
         print(cpNodes)
         }
         */
        
        /**
         let animation = artboard.getAnimation(name: "Idle")
         currentAnimTime += (animTime - currentAnimTime) * min(1, elapsed * 5)
         animation?.apply(
         time: currentAnimTime * animation!.duration,
         artboard: artboard,
         mix: 1
         )
         */
        
        var lastFullyMixed = -1
        var lastMix = 0.0
        
        var completed = [FlareAnimationLayer]()
        
        var arrayEvent =  Array<AnimationEventArgs>()
        
        for i in 0..<controlLayers.count {
            
            let layer = controlLayers[i]
            
            currentAnimTime = layer.time;
            
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
            
            //            // EVENT TEST:
            //            if(animation == nil)
            //            {
            //                animation = artboard.getAnimation(name: "Mustache_New")
            //            }
            
            animation?.triggerEvents(components: artboard.components! as! Array<ActorComponent>, fromTime: currentAnimTime, toTime: layer.time, triggerEvents: &arrayEvent)
            
            for i in 0 ..< arrayEvent.count {
                print(arrayEvent[i].name)
                if(arrayEvent[i].name == "Event"){
                    //do something
                }
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
    
    override open func setViewTransform(viewTransform: Mat2D) {}
    
}
