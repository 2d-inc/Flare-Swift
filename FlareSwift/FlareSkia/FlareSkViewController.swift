//
//  FlareSkViewController.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 10/8/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import Skia
import os.log

protocol FlareController {
    func initialize()
    func setViewTransform(viewTransform: Mat2D)
    func advance(elapsed: Double)
}

public typealias CompletedAnimationCallback = (String) -> ()

public class FlareSkViewController: UIViewController, FlareController {
    private let bundleCache = BundleCache.storage

    private let filename: String
    private let assetBundle: Bundle
    private var flareViewFrame: CGRect
    private var displayLink: CADisplayLink?
    
    internal var _animationName: String?
    internal var boundsNodeName: String?
    internal var artboardIndex = 0
    internal var snapToEnd = false
    internal var isPaused = false
    internal var completedCallback: CompletedAnimationCallback?
    
    private var setupAABB: AABB?
    private var assets = [SkCacheAsset]()
    private var animationLayers: [FlareAnimationLayer] = []
    private var lastTime = 0.0
    private var _isLoading = false
    
    private var isPlaying: Bool {
        return !isPaused && !animationLayers.isEmpty
    }
    
    internal var isLoading: Bool { return _isLoading }
    internal var aabb: AABB? { return setupAABB }
    
    public var completed: CompletedAnimationCallback? {
        get { return completedCallback }
        set {
            /// Closures cannot be tested on equality in Swift:
            /// http://bit.ly/2MHp0dV
            /// So every time we set the callback, it gets overridden
            completedCallback = newValue
        }
    }
    
    public var animationName: String? {
        get { return _animationName }
        set {
            if _animationName != newValue {
                _animationName = newValue
                updateAnimation()
            }
        }
    }
    
    public var flareView: FlareSkView? { return view as? FlareSkView }
    
    init(for filename: String,
                _ frame: CGRect = UIScreen.main.bounds,
                _ sourceBundle: Bundle = Bundle.main) {
        guard filename.hasSuffix(".flr") else {
            fatalError("FlareController init() needs a .flr file")
        }
        
        self.filename = filename
        assetBundle = sourceBundle
        flareViewFrame = frame
        // Per documentation, init with nil values.
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("No coder init allowed for FlareSkViewController")
    }
    
    /** TODO:
     - alignment
     - fit
     - on resize
     */
    
    override public func loadView() {
        view = FlareSkView(frame: flareViewFrame)
        if assets.isEmpty {
            _load()
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        flareViewFrame = self.view.bounds
        updateAnimation(onlyWhenMissing: true)
//        print("Change Bounds: \(self.view.bounds)")
    }
    
    override public func viewDidLayoutSubviews() {
        /**
         When bounds change for a view controller's view, the view adjust the positions of its subviews and then the system calls this method.
         */
        #warning("TODO: check correctness")
        super.viewDidLayoutSubviews()
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
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
    
    func load() {
        guard let view = view as? FlareSkView else {
            os_log("flareView isn't available!", type: .debug)
            return
        }

        view.actor = loadFlare(filename)
        if
            !instanceArtboard() // Checks that the actor and its artboard have been loaded.
        {
            os_log("Couldn't instance the artboard", type: .debug)
            return
        }
    }
    
    private func _load() {
        guard !_isLoading else { return }
        _isLoading = true
        _unload()
        load()
        _isLoading = false
    }
    
    private func _unload() {
        for asset in assets {
            bundleCache.deref(in: assetBundle.bundleIdentifier!, for: asset)
        }
        assets.removeAll()
        onUnload()
    }
    
    func loadFlare(_ filename: String) -> FlareSkActor? {
        guard
            !filename.isEmpty,
            let bundleId = Bundle.main.bundleIdentifier
        else {
                return nil
        }

        if let asset = bundleCache.cachedAsset(bundle: bundleId, filename: filename) {
            assets.append(asset)
            return asset.value
        } else {
            return nil
        }
    }
    
    public func onUnload() {}
    
    private func instanceArtboard() -> Bool {
        guard
            let view = view as? FlareSkView,
            let actor = view.actor,
            let _ = actor.artboard
        else { return false }
        
        /// getArtboard() could return `nil`.
        /// If it does, something went wrong at `load()` time.
        let instance = actor
            .getArtboard(artboardIndex)!
            .makeInstance() as! FlareSkArtboard
        instance.initializeGraphics()
        
        // Initialize controller.
        self.initialize()
        updateAnimation(onlyWhenMissing: true)

        // Set the artboard and advance(0)
        view.artboard = instance
        view.updateBounds()
        
        
        return true
    }

    /**
    private func bindView() {
        guard let fView = flareView else {
            return
        }

        // View in this case is the default view
        view.addSubview(fView)
        // Constrain if needed.
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    */
    
    func setViewTransform(viewTransform: Mat2D) {}
    func initialize() {}
    func advanceControls(by elapsed: Double) -> Bool { return false }
    func advance(elapsed: Double) {
        guard
            let view = view as? FlareSkView,
            let artboard = view.artboard
        else { return }

        if isPlaying {
            var lastFullyMixed = -1
            var lastMix = 0.0
            
            var completed = [FlareAnimationLayer]()
            
            for layerIndex in 0..<animationLayers.count {
                let layer = animationLayers[layerIndex]
                if snapToEnd && !layer.isLooping {
                    layer.mix = 1.0
                    layer.time = layer.duration
                } else {
                    layer.mix += elapsed
                    layer.time += elapsed
                }

                lastMix = (layer.mixSeconds == 0.0)
                    ? 1.0
                    : min(1.0, layer.mix / layer.mixSeconds)
                
                if layer.isLooping {
                    layer.time = layer.time.truncatingRemainder(dividingBy: layer.duration)
                }

                // Apply the animation specifying a mix.
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
            if !advanceControls(by: elapsed) { }
            
            artboard.advance()
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        updatePlayState()
    }
    
    private func updatePlayState() {
        /// (viewIfLoaded?.window) != nil checks if the view is still attached
        if isPlaying && (viewIfLoaded?.window != nil) {
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
        guard let view = view as? FlareSkView else {
            return
        }
        let currentTime = CACurrentMediaTime()
        let delta = lastTime == 0 ? 0.0 : (currentTime - lastTime)
        lastTime = currentTime
        
        advance(elapsed: delta)
        if !isPlaying {
            lastTime = 0.0
        }
        view.paint()
    }
    
    private func updateAnimation(onlyWhenMissing: Bool = false) {
        if onlyWhenMissing && !animationLayers.isEmpty {
            return
        }
        
        guard
            let view = view as? FlareSkView,
            let name = _animationName,
            let artboard = view.artboard
        else { return }
        
        if let animation = artboard.getAnimation(name: name) {
            animationLayers.append(
                FlareAnimationLayer(animation, name: name, mix: 1.0)
            )
            animation.apply(time: 0.0, artboard: artboard, mix: 1.0)
            artboard.advance()
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
