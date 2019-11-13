//
//  ExampleController.swift
//  BasicExample
//
//  Created by Mandy Lowry on 11/11/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import UIKit
import FlareSwift
//import class FlareSwift.ActorNodeSolo

class ExampleController: UIViewController {
    
    private var button: UIButton!
    private var flareController: CustomController? = nil
    private var soloNode: ActorNodeSolo? = nil
    private var artboard: ActorArtboard? = nil
  
    var count: Int = 1
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor.lightGray
        
        let frame = UIScreen.main.bounds
        
        flareController = CustomController(for: "Cactus_Test_CP_EV.flr", CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        flareController!.animationName = "Idle"
        addChild(flareController!)
        
        if let fView = flareController!.view {
            view.addSubview(fView)
            fView.translatesAutoresizingMaskIntoConstraints = false
            flareController!.didMove(toParent: self)
        } else {
            /* Something went wrong? */
            print("Couldn't get FlareController subview?")
        }
        let fView = flareController?.view as? FlareSkView
        artboard = fView?.artboard
             
        //get ref of solo node for button here
        soloNode = artboard?.getNode(name: "Mustache_Solo") as? ActorNodeSolo
        
        /*
        * UNCOMMENT TO TEST
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
                
        button = UIButton(frame: CGRect(x: 50, y: 50, width: frame.width * 0.5, height: frame.height * 0.10))
        button.backgroundColor = UIColor.red
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Change Mustache", for: .normal)
        button.addTarget(self, action: #selector(onTap), for: .touchUpInside)
        view.addSubview(button)

    }

    @objc func onTap() {
               
        self.flareController!.play(name: "Mustache_New")//, mix: 0.5, mixSeconds: 1.0
              
        count += 1
        if(count > 5){
            count = 1;
        }
        soloNode?.setActiveChildIndex(count)
       // print(soloNode?.activeChildIndex as Any)
        
    }
}
