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

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: {
            timer in
                self.button.sendActions(for: .touchUpInside)
        })
        
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false, block: {
            timer in
                self.flareController?.play(name: "On")
        })
    }

    @objc func onTap() {
//        print("TAP!")
        if flareController == nil {
            let fBuilder = FlareSkControlsBuilder(
                for: "Switch.flr",
                frame: CGRect(x: 50, y: 100, width: 800, height: 600)
            )

            flareController =
                fBuilder
//                    .with(animationName: "walk")
                    .with(shouldClip: true)
                    .build()

            addChild(flareController!)
            

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

