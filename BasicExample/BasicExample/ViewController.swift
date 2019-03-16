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
    
    @IBOutlet weak var flareExample: FlareView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1)
        flareExample.backgroundColor = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1)
        // Initiate Flare file load with the filename setter
        flareExample.filename = "Notification Bell.flr"
    }


}

