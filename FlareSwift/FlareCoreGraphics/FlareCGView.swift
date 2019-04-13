//
//  FlareCGView.swift
//  FlareSwift
//
//  Created by Artur Rymarz on 15/03/2019.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import UIKit

@IBDesignable
public class FlareCGView: UIView {
    private var displayLink: CADisplayLink?

    private var _filename: String = ""

    private var flareActor: FlareCGActor!
    private var artboard: FlareCGArtboard?
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

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
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

                if _filename.isEmpty || !_filename.hasSuffix(".flr") {
                    setNeedsDisplay()
                    return
                }

                let fActor = FlareCGActor()
                if fActor.loadFromBundle(filename: _filename) {
                    flareActor = fActor
                    artboard = fActor.artboard
                    if let ab = artboard {
                        ab.initializeGraphics()
                        ab.overrideColor = self.colorArray
                        ab.advance(seconds: 0.0)
                        updateBounds()
                    }
                    
                    extractImageData()
                    
                    updateAnimation(onlyWhenMissing: true)
                    setNeedsDisplay()
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
            guard
                let c = _color,
                let colorSpaceModel = c.colorSpace?.model,
                let components = c.components
            else {
                return nil
            }

            let fComponents = components.map { Float($0) }

            switch colorSpaceModel {
            case .rgb:
                return [fComponents[0],
                        fComponents[1],
                        fComponents[2],
                        fComponents[3]]
            case .monochrome:
                return [fComponents[0],
                        fComponents[0],
                        fComponents[0],
                        fComponents[1]]
            default:
                return nil
            }
        }
    }

    private func updateBounds() {
        guard let actor = flareActor else {
            return
        }

        setupAABB = actor.artboard?.artboardAABB()
    }
    
    func extractImageData() {
        if let ab = artboard {
            let images = ab.drawableNodes.compactMap{ $0 as? ActorImage }
            if images.count > 0, let animations = ab.animations {
                for animation in animations {
                    let deltaTime = Double(1/animation._fps)
                    var time: Double = animation.duration/3
                    
//                    while(time <= animation.duration) {
                    animation.apply(time: time, artboard: ab, mix: 1.0)
                    ab.advance(seconds: deltaTime)
//                        time += deltaTime
//                    }
                }
            }
        }
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
                lastTime = CACurrentMediaTime()
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

        if let animation = self.animation, let artboard = self.artboard {
            let currentTime = CACurrentMediaTime()
            let delta = currentTime - lastTime
            lastTime = currentTime
            duration = (duration + delta)
//            if animation.isLooping {
                duration = duration.truncatingRemainder(dividingBy: animation.duration)
//            }
            animation.apply(time: duration, artboard: artboard, mix: 1.0)
            artboard.advance(seconds: delta)
            setNeedsDisplay()
        }
    }

    override public func draw(_ rect: CGRect) {
        guard
            let ctx = UIGraphicsGetCurrentContext(),
            let artboard = flareActor?.artboard,
            let bounds = setupAABB
        else {
            return
        }

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
        
        backgroundColor = UIColor.red

//        artboard.draw(context: ctx)
//        artboard.draw(context: ctx, on: layer)
        let iScale = 1/scale
        let imageRect = CGRect(x: 0, y: 0, width: iScale * rect.width, height: iScale * rect.height)
        let flareImages = artboard.drawableNodes.compactMap{$0 as? FlareCGImage}
        for fi in flareImages {
            if let cgImage = fi._displayImage {
                
//                ctx.setBlendMode(.sourceAtop)
                ctx.draw(cgImage, in: imageRect)
            }
        }

        ctx.restoreGState()
    }
    
}
