//
//  ViewController.swift
//  BasicExample
//
//  Created by Umberto Sonnino on 2/28/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import UIKit
import FlareSwift

class ViewController: UIViewController {
    
    private var button: UIButton!
    private let addLabel = "Add Flare"
    private let removeLabel = "Remove Flare"
    private var flareController: FlareSkControls? = nil
    private var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGray
        button = UIButton(frame: CGRect(x: 50, y: 50, width: 150, height: 50))
        button.backgroundColor = UIColor.red
        button.setTitleColor(.white, for: .normal)
        button.setTitle(addLabel, for: .normal)
        button.addTarget(self, action: #selector(onTap), for: .touchUpInside)
        view.addSubview(button)
    }

    /// Callback for the button on screen: Add a FlareSkViewController if not present,
    /// otherwise remove it.
    @objc func onTap() {
        if flareController == nil {
            let currentFrame = self.view.frame
            let x = CGFloat(50)
            let y = CGFloat(100)
            let w = min(currentFrame.width - (x*2), 800)
            let h = min(currentFrame.height - (y*2), 600)
            let fBuilder = FlareSkControlsBuilder(
                for: "Switch.flr",
                frame: CGRect(x: x, y: y, width: w, height: h)
            )

            /// Use `FlareSkControlsBuilder` to instantiate a FlareController
            /// chaining together multiple `with()` calls for adding parameters.
            /// Look at the `FlareSkControlsBuilder` class for more insights.
            flareController =
                fBuilder
                    .with(animationName: "Full Loop")
                    .with(shouldClip: true)
                    .build()

            self.addChild(flareController!)

            // Sanity check.
            if let fView = flareController!.view {
                view.addSubview(fView)
                fView.translatesAutoresizingMaskIntoConstraints = false
                flareController!.didMove(toParent: self)
            } else {
                /* Something went wrong? */
                print("Couldn't get FlareController subview?")
            }

            button.setTitle(removeLabel, for: .normal)
        } else {
            flareController?.view.removeFromSuperview()
            flareController = nil
            button.setTitle(addLabel, for: .normal)
        }
    }
}

