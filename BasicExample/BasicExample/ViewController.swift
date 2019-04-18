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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGray
        
        let frame = UIScreen.main.bounds
        let flareView = FlareSkView(frame: CGRect(x: 100, y: 100, width: frame.size.width-200, height: frame.size.height-200))
        view.addSubview(flareView)
        flareView.filename = "Switch.flr"
    }


}

