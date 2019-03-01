//
//  FlareExample.swift
//  example
//
//  Created by Umberto Sonnino on 2/8/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import UIKit
import FlareSwift

@IBDesignable
class FlareExample: UIView {
    
    private var flareActor: FlareActor!
    private var displayLink: CADisplayLink!
    private var lastTime = 0.0
    private var duration = 0.0
    private var animationName = "Test"
    private var setupAABB: AABB!
    private var artboard: FlareArtboard!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        fatalError("init(coder:) has not been implemented")
        setupView()
    }
    
    private func updateBounds() {
        guard let actor = flareActor else {
            return
        }
        
        setupAABB = actor.artboard?.artboardAABB()
    }
    
    private func setupView() {
        print("INIT!")
        let path = Bundle.main.path(forResource: "Circle", ofType: "flr")
        if (path != nil) {
            print("FILE EXISTS! \(String(describing: path))")
            if let data = FileManager.default.contents(atPath: path!) {
//                _ = String(data: data[0...4], encoding: String.Encoding.utf8) as! String
                flareActor = FlareActor()
                flareActor.load(data: data)
                artboard = flareActor.artboard
                if artboard != nil {
                    artboard.initializeGraphics()
                    // TODO: artboard.overrideColor =
                    artboard.advance(seconds: 0.0)
                    updateBounds()
                    
                    lastTime = CACurrentMediaTime()
                    displayLink = CADisplayLink(target: self, selector: #selector(beginFrame))
                    displayLink.add(to: .current, forMode: .common)
                }
                
            }
        }
        else {
            print("HAVEN'T GOTTEN IT! =(")
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                print(fileURLs)
            } catch {
                print("ERROR ENUMMING FILES: \(documentsURL.path), \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func beginFrame() {
        guard flareActor != nil else {
//          TODO: updatePlayState()
            return
        }
        
        let currentTime = displayLink.timestamp
        let delta = currentTime - lastTime
        lastTime = currentTime
        duration += delta
//        print("TRYING THIS OUT: \(delta), \(lastTime)")
//        if duration > 2.0 {
//            displayLink.invalidate()
//        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let artboard = flareActor.artboard else {
            return
        }
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
//
//        let path = UIBezierPath(ovalIn: rect)
//        UIColor.red.setFill()
//        path.fill()
        backgroundColor = UIColor.lightGray
        if let bounds = setupAABB {
            let contentWidth = bounds[2] - bounds[0]
            let contentHeight = bounds[3] - bounds[1]
//            let x = bounds[0] - contentWidth / 2
//            let y = bounds[1] - contentHeight / 2
            
            // Contain the artboard
            let scaleX = rect.width / CGFloat(contentWidth)
            let scaleY = rect.height / CGFloat(contentHeight)
            let scale = min(scaleX, scaleY)
            ctx.saveGState()
            ctx.scaleBy(x: scale, y: scale)
//            ctx.translateBy(x: 5, y: 5)
//            ctx.setFillColor(UIColor.red.cgColor)
//            ctx.fill(CGRect(x: 0, y: 0, width: Double(contentWidth), height: Double(contentHeight)))
            artboard.draw(context: ctx)
            ctx.restoreGState()
        }
//        print("HERE! \(duration)")
    }
}
