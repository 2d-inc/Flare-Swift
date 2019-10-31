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
    private var flareController: FlareSkViewController? = nil
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
        
        print("viewDidLoad")
    }

    @objc func onTap() {
//        print("TAP!")
        if flareController != nil {
            flareController?.view.removeFromSuperview()
            flareController = nil
            button.setTitle(addLabel, for: .normal)
        } else {
            flareController = FlareSkViewController(for: "Shape.flr", frame: CGRect(origin: CGPoint(x: 50, y: 100), size: CGSize(width: 800, height: 600)))
            flareController!.animationName = "Move"
            view.addSubview(flareController!.view)
            button.setTitle(removeLabel, for: .normal)
            
        }
    }
}

