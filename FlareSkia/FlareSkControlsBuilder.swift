//
//  FlareSkControllerBuilder.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 11/7/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

/// This is a helper object to build a custom FlareSkControls.
/// Its constructor needs a Flare file name and a frame size
/// for the View that it'll build.
///
/// All the other fields are optional parameters that can be specified to
/// customize the FlareSkControls that we want it to build.
/// Usage:
///     let fBuilder = FlareSkControlsBuilder()
///     let flare: FlareSkControls =
///         fBuilder
///             .with(animationName: "Idle") // Specify custom parameters
///             .with(shouldClip: true)
///             .with(artboard: 2) // Indices start at 0
///             .build() // Finally build the object and return it.

public class FlareSkControlsBuilder {
    private var viewFrame: CGRect
    private var filename: String
    
    private var animationName: String?
    private var boundsNodeName: String?
    
    private var artboardIndex: Int = 0
    
    private var snapToEnd: Bool = false
    private var isPaused: Bool = false
    private var shouldClip: Bool = true
// TODO:    private var sizeFromArtboard: Bool = false
    
    private var color: UIColor?
    
    private var callback: CompletedAnimationCallback?
    
    public init(for filename: String, frame: CGRect) {
        self.filename = filename
        self.viewFrame = frame
    }
    
    public func with(animationName: String) -> FlareSkControlsBuilder {
        self.animationName = animationName
        return self
    }
    public func with(boundsNode: String) -> FlareSkControlsBuilder {
        self.boundsNodeName = boundsNode
        return self
    }
    public func with(artboard: Int) -> FlareSkControlsBuilder {
        self.artboardIndex = artboard
        return self
    }
    public func with(snapEnd: Bool) -> FlareSkControlsBuilder {
        self.snapToEnd = snapEnd
        return self
    }
    public func with(isPaused: Bool) -> FlareSkControlsBuilder {
        self.isPaused = isPaused
        return self
    }
    public func with(shouldClip: Bool) -> FlareSkControlsBuilder {
        self.shouldClip = shouldClip
        return self
    }
    
    public func build() -> FlareSkControls {
        let flareController = FlareSkControls(for: self.filename, viewFrame)

        flareController.animationName = self.animationName
        flareController.boundsNodeName = self.boundsNodeName
        flareController.artboardIndex = self.artboardIndex
        flareController.snapToEnd = self.snapToEnd
        flareController.isPaused = self.isPaused
        flareController.flareView?.shouldClip = self.shouldClip
        flareController.flareView?.color = self.color
        flareController.completedCallback = self.callback

        return flareController
    }
}
