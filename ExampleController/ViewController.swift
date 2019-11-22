//
//  ViewController.swift
//  ExampleController
//
//  Created by Umberto Sonnino on 11/21/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import UIKit
/// To use on a physical device.
//import FlareSwift
/// To use on a Simulator.
import FlareSwiftDev

class ViewController: UIViewController {

    private var button: UIButton!
    private var flareController: CustomController? = nil
    private var soloNode: ActorNodeSolo? = nil
    private var artboard: ActorArtboard? = nil
    
    var count: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.darkGray
        
        let screenFrame = UIScreen.main.bounds
        
        let x = CGFloat(50)
        let y = CGFloat(200)
        
        flareController = CustomController(
            for: "Cactus.flr",
            CGRect(x: x, y: y, width: screenFrame.width - (x*2), height: screenFrame.height - (y*2))
        )
        flareController!.animationName = "Idle"
        addChild(flareController!)
        
        if let fView = flareController!.view as? FlareSkView {
            view.addSubview(fView)
            fView.translatesAutoresizingMaskIntoConstraints = false
            flareController!.didMove(toParent: self)
            // Assign the artboard reference.
            artboard = fView.artboard
            // Assign the Node Solo reference.
            soloNode = artboard?.getNode(name: "Mustache_Solo") as? ActorNodeSolo
            
            /** UNCOMMENT TO TEST
            let myNode = artboard?.getNode(name: "Face")
            print(myNode?.x)
            print(myNode?.y)
            print(myNode?.scaleX)
            print(myNode?.scaleY)
            print(myNode?.rotation)
            print(myNode?.opacity)
            print(artboard?.getNode(name: "Scale Node_Special Property")?.name)
               
            let boneNode = artboard?.getNode(name: "Bone") as? ActorBoneBase
            print(boneNode?.length as Any)
            */
            let buttonWidth = screenFrame.width/2
            button = UIButton(frame: CGRect(x: buttonWidth/2, y: 50, width: buttonWidth, height: 100))
            button.backgroundColor = UIColor.systemIndigo
            button.setTitleColor(.white, for: .normal)
            button.setTitle("Change Mustache", for: .normal)
            button.addTarget(self, action: #selector(onTap), for: .touchUpInside)
            view.addSubview(button)
        } else {
            /* Something went wrong? */
            print("Couldn't get FlareController subview?")
        }
    }
    
    @objc func onTap() {
               
        self.flareController!.play(name: "Mustache_New")//, mix: 0.5, mixSeconds: 1.0
              
        count += 1
        if(count > 5){
            count = 1;
        }
        soloNode?.setActiveChildIndex(count)
        
    }


}

