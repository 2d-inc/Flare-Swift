//
//  FlareExample.swift
//  example
//
//  Created by Umberto Sonnino on 2/8/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import UIKit
import FlareSwift

@IBDesignable
class FlareExample: UIView {
    private var displayLink: CADisplayLink?
    
    private var _filename: String = ""
    
    private var flareActor: FlareActor!
    private var artboard: FlareArtboard?
    private var animation: ActorAnimation?
    private var setupAABB: AABB!
    private var animationName: String?
    
    private var lastTime = 0.0
    private var duration = 0.0
    private var animationTime = 0.0
    private var isPlaying = true
    private var shouldClip = true
    
    private var _color: CGColor?
    // TODO: animation layers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    public var filename: String {
        get {
            return _filename
        }
        set {
            if newValue != _filename {
                _filename = newValue
                if flareActor != nil {
                    flareActor.dispose()
                    flareActor = nil
                    artboard = nil
                }
//                animationLayers.removeAll()
                
                if _filename.isEmpty || !_filename.hasSuffix(".flr") {
                    setNeedsDisplay()
                    return
                }
                
                let fActor = FlareActor()
                if fActor.loadFromBundle(filename: _filename) {
                    flareActor = fActor
                    artboard = fActor.artboard
                    if let ab = artboard {
                        ab.initializeGraphics()
                        ab.overrideColor = self.colorArray
                        ab.advance(seconds: 0.0)
                        updateBounds()
                    }
                    
                    updateAnimation(onlyWhenMissing: true)
                    setNeedsDisplay()
                    updatePlayState()
                }
            }
        }
    }
    
    public var color: CGColor? {
        get {
            return _color
        }
        set {
            if newValue != _color {
                _color = newValue
                if let ab = artboard {
                    ab.overrideColor = self.colorArray
                }
                setNeedsDisplay()
            }
        }
    }
    
    private var colorArray: [Float]? {
        get {
            if let c = _color {
                if let components = c.components {
                    return [Float(components[0]),
                            Float(components[1]),
                            Float(components[2]),
                            Float(components[3])]
                }
            }
            return nil
        }
    }
    
    private func updateBounds() {
        guard let actor = flareActor else {
            return
        }
        
        setupAABB = actor.artboard?.artboardAABB()
    }
    
    private func updateAnimation(onlyWhenMissing: Bool = false) {
//        if let aName = animationName, let ab = artboard {
//            if let a = ab.getAnimation(name: aName) {
        if let ab = artboard {
            if let a = ab.animations?.first {
                self.animation = a
                a.apply(time: 0.0, artboard: ab, mix: 1.0)
                ab.advance(seconds: 0.0)
            }
            updatePlayState()
        }
    }
    
    private func updatePlayState() {
        if isPlaying && !isHidden {
            if displayLink == nil {
                displayLink = CADisplayLink(target: self, selector: #selector(beginFrame))
                displayLink!.add(to: .current, forMode: .common)
            }
        } else {
            if let dl = displayLink {
                dl.invalidate()
                displayLink = nil
            }
            lastTime = 0.0
        }
    }
    
    @objc private func beginFrame() {
        guard flareActor != nil else {
            updatePlayState()
            return
        }
        
        if let animation = self.animation, let artboard = self.artboard, let displayLink = self.displayLink {
            let currentTime = displayLink.timestamp
            let delta = currentTime - lastTime
            lastTime = currentTime
            duration = (duration + delta)
            if animation.isLooping {
                duration = duration.truncatingRemainder(dividingBy: animation.duration)
            }
            animation.apply(time: duration, artboard: artboard, mix: 1.0)
            artboard.advance(seconds: delta)
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let artboard = flareActor?.artboard else {
            return
        }
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }

        backgroundColor = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1)
        if let bounds = setupAABB {
            let contentWidth = CGFloat(bounds[2] - bounds[0])
            let contentHeight = CGFloat(bounds[3] - bounds[1])

            let x = contentWidth * CGFloat(artboard.origin.x)
            let y = contentHeight * CGFloat(artboard.origin.y)
            
            // Contain the artboard
            let scaleX = rect.width / contentWidth
            let scaleY = rect.height / contentHeight
            let scale = min(scaleX, scaleY)
            
            ctx.saveGState()
            ctx.scaleBy(x: scale, y: scale)
            ctx.translateBy(x: x, y: y)
            
            artboard.draw(context: ctx)
            
            ctx.restoreGState()
        }
    }
}
