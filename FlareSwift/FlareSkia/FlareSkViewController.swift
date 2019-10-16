//
//  FlareSkViewController.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 10/8/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import Skia

protocol FlareController {
    func initialize()
    func setViewTransform(viewTransform: Mat2D)
    func advance(elapsed: Double)
}

class FlareSkViewController: UIViewController, FlareController {
    /**
     Mat2D _lastControllerViewTransform;
     */
    private var assetBundle: Bundle
    private var displayLink: CADisplayLink?
    private var flareView: FlareSkView!
    private var flareActor: FlareSkActor!
    private var artboard: FlareSkArtboard?
    private var artboardName: String?
    private var boundsNodeName: String?
    private var setupAABB: AABB?
    
    private var assets = [SkCacheAsset]()
    private var animationLayers: [FlareAnimationLayer] = []
    typealias CompletedAnimationCallback = (String) -> ()
    private var completedCallback: CompletedAnimationCallback?
    
    private var lastTime = 0.0
    private var _isLoading = false
    private var _isPlaying = false
    private var _isPaused = false
    
    private var _actor: FlareSkActor?
    
    private var _animationName: String?
    private var _filename: String = ""
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
            }
            
            if _filename.isEmpty || !_filename.hasSuffix(".flr") {
                flareView.setNeedsDisplay()
                return
            }
        }
    }
    
    public var completed: CompletedAnimationCallback? {
        get { return completedCallback }
        set {
            /// Closures cannot be tested on equality in Swift:
            /// http://bit.ly/2MHp0dV
            /// So every time we set the callback, it gets overridden
            completedCallback = newValue
        }
    }
    
    var isLoading: Bool { return _isLoading }
    var aabb: AABB? { return setupAABB }
    
    init(_ sourceBundle: Bundle = Bundle.main) {
        assetBundle = sourceBundle
        // Per documentation, init with nil values.
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("No coder init allowed for FlareSkViewController")
    }
    
    /**
     TODO:
     - alignment
     - fit
     - on resize
     - on detach
     - load Flare from Cache
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flareView = FlareSkView(frame: self.view.bounds)
        if assets.isEmpty {
            _load()
        }
        bindView()
    }
    
    override func viewDidLayoutSubviews() {
        /**
         When bounds change for a view controller's view, the view adjust the positions of its subviews and then the system calls this method.
         */
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        /**
         Notifies the view controller that its view was removed from a view hierarchy.
         */
        super.viewDidDisappear(animated)
        dispose()
    }
    
    private func dispose() {
        updatePlayState()
        _unload()
    }
    
    func load() {}
    
    private func _load() {
        guard !_isLoading else { return }
        _isLoading = true
        _unload()
        load()
        _isLoading = false
    }
    
    private func _unload() {
        for asset in assets {
            asset.deref()
        }
        assets.removeAll()
        onUnload()
    }
    
    func loadFlare(filename: String) -> FlareSkActor? {
        guard
            !filename.isEmpty,
            let bundleId = Bundle.main.bundleIdentifier
        else {
                return nil
        }

        if let asset = cachedActor(bundle: bundleId, filename: filename) {
            asset.ref()
            assets.append(asset)
            return asset.value
        } else {
            return nil
        }
    }
    
    public func onUnload() {}
    
    private func instanceArtboard() -> Bool {
        guard
            let actor = _actor,
            let _ = actor.artboard
        else { return false }
        
        /// getArtboard() could return `nil`.
        /// If it does something went wrong at `load()` time.
        let instance = actor
            .getArtboard(name: artboardName)!
            .makeInstance() as! FlareSkArtboard
        instance.initializeGraphics()
        artboard = instance
        let actorColor = actor.color
        // Call the setter? Might not be needed.
        actor.color = actorColor
        artboard!.advance(seconds: 0.0)
        updateBounds()
        
        // Initialize controller.
        self.initialize()
        
        updateAnimation(onlyWhenMissing: true)
        
        return true
    }
    
    func updateBounds() {
        if let ab = artboard {
            if let boundsNode = boundsNodeName,
                let node = ab.getNode(name: boundsNode) as? ActorDrawable {
                flareView.setupAABB = node.computeAABB()
            } else {
                flareView.setupAABB = ab.artboardAABB()
            }
        }
    }
    
    private func bindView() {
        view.addSubview(flareView)
        // Constrain if needed.
        flareView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setViewTransform(viewTransform: Mat2D) {}
    func initialize() {}
    func advance(elapsed: Double) {
        guard let artboard = artboard else { return }
        if _isPlaying {
            var lastFullyMixed = -1
            var lastMix = 0.0
            
            var completed = [FlareAnimationLayer]()
            
            for layerIndex in 0..<animationLayers.count {
                let layer = animationLayers[layerIndex]
                if /** snapToEnd && */ !layer.isLooping {
                    layer.mix = 1.0
                    layer.time = layer.duration
                } else {
                    layer.mix += elapsed
                    layer.time += elapsed
                }
                
                lastMix = layer.mixSeconds == 0.0 ? 1.0 : min(1.0, layer.mix / layer.mixSeconds)
                if layer.isLooping {
                    // layer.time %= layer.duration
                    layer.time = layer.time.truncatingRemainder(dividingBy: layer.duration)
                }
                // Effectively apply the animation.
                layer.animation.apply(time: layer.time, artboard: artboard, mix: Float(lastMix))
                if lastMix == 1.0 {
                    lastFullyMixed = layerIndex
                }
                if layer.time > layer.duration {
                    completed.append(layer)
                }
            }
            
            if lastFullyMixed != -1 {
                animationLayers.removeSubrange(0..<lastFullyMixed)
            }
            if _animationName == nil && animationLayers.count == 1 && lastMix == 1.0 {
                // Remove remaining animations.
                animationLayers.remove(at: 0)
            }
            
            for animation in completed {
                animationLayers.removeAll { $0 === animation }
                if let callback = completedCallback {
                    callback(animation.name)
                }
            }
        }
    }
    
    private func updatePlayState() {
        /// (viewIfLoaded?.window) != nil checks if the view is still attached
        if _isPlaying && (viewIfLoaded?.window != nil) {
            if displayLink == nil {
                displayLink = CADisplayLink(target: self, selector: #selector(beginFrame))
                lastTime = CACurrentMediaTime()
                displayLink!.add(to: .current, forMode: .common)
            }
        } else {
            lastTime = 0.0
            if let dl = displayLink {
                dl.invalidate()
                displayLink = nil
            }
        }
    }
    
    @objc private func beginFrame() {
        guard flareActor != nil else {
            updatePlayState()
            return
        }
        let currentTime = CACurrentMediaTime()
        let delta = lastTime == 0 ? 0.0 : (currentTime - lastTime)
        lastTime = currentTime
        
        advance(elapsed: delta)
        if !_isPlaying {
            lastTime = 0.0
        }
        flareView.paint()
    }
    
    private func updateAnimation(onlyWhenMissing: Bool = false) {
        if onlyWhenMissing && !animationLayers.isEmpty {
            return
        }
        
        guard
            let name = _animationName,
            let artboard = artboard
        else { return }
        
        if let animation = artboard.getAnimation(name: name) {
            animationLayers.append(
                FlareAnimationLayer(animation, name: name, mix: 1.0)
            )
            animation.apply(time: 0.0, artboard: artboard, mix: 1.0)
            artboard.advance(seconds: 0.0)
            updatePlayState()
        }
    }
    
}

class FlareAnimationLayer {
    let name: String
    let animation: ActorAnimation
    var time: Double
    var mix: Double
    var mixSeconds: Double
    
    var duration: Double {
        return animation.duration
    }
    var isDone: Bool {
        return time >= animation.duration
    }
    var isLooping: Bool {
        return animation.isLooping
    }
    
    init(_ animation: ActorAnimation, name: String = "",
         time: Double = 0.0, mix: Double = 0.0, mixSeconds: Double = 0.2)
    {
        self.animation = animation
        self.name = name
        self.time = time
        self.mix = mix
        self.mixSeconds = mixSeconds
    }
    
    func apply(artboard: FlareSkArtboard) {
        animation.apply(time: time, artboard: artboard, mix: Float(mix))
    }
}
