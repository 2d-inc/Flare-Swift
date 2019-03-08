//
//  FlareSwiftTests.swift
//  FlareSwiftTests
//
//  Created by Umberto Sonnino on 2/28/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import XCTest
@testable import FlareSwift

class FlareSwiftTests: XCTestCase {
    let delta: Float = 0.00001

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testBezierConstruction() {
        let points = [
            Vec2D(fromValues: 10.0, 10.0),
            Vec2D(fromValues: 70.0, 95.0),
            Vec2D(fromValues: 25.0, 20.0),
            Vec2D(fromValues: 15.0, 80.0)
        ]
        let curve = CubicBezier(points)
        
        XCTAssertEqual(curve.order, 3)
        XCTAssertEqual(curve.points.count, 4)
    }
    
    func testBezierFactory() {
        let points = [
            Vec2D(),
            Vec2D(fromValues: 250.0, -50.0),
            Vec2D(fromValues: 100.0, 80.0)
        ]
        
        let curve = BezierFactory.fromPoints(points)
        
        XCTAssert(curve is QuadraticBezier)
        XCTAssert(curve.order == 2)
        XCTAssert(curve.points.count == 3)
        
//        points.append(contentsOf: [Vec2D(fromValues: 100.0, -100.0), Vec2D(fromValues: -30, 100)])
//        let failCurve = BezierFactory.fromPoints(points)
    }
    
    func testLeftSubcurveAt() {
        let curve = QuadraticBezier( [ Vec2D(), Vec2D(fromValues: 50, 100), Vec2D(fromValues: 100, 0) ] )
        
        let result1 = curve.leftSubcurveAt(0.5)
        XCTAssert(result1 is QuadraticBezier)
        let qCurve1 = result1 as! QuadraticBezier
        var distance = Vec2D.distanceSquared(qCurve1.points[0], Vec2D(fromValues: 0, 0))
        XCTAssert(distance < delta)
        distance = Vec2D.distanceSquared(qCurve1.points[1], Vec2D(fromValues: 25, 50))
        XCTAssert(distance < delta)
        distance = Vec2D.distanceSquared(qCurve1.points[2], Vec2D(fromValues: 50, 50))
        XCTAssert(distance < delta)
        
        let result2 = curve.leftSubcurveAt(0.8)
        XCTAssert(result1 is QuadraticBezier)
        let qCurve2 = result2 as! QuadraticBezier
        distance = Vec2D.distanceSquared(qCurve2.points[0], Vec2D(fromValues: 0, 0))
        XCTAssert(distance < delta)
        distance = Vec2D.distanceSquared(qCurve2.points[1], Vec2D(fromValues: 40, 80))
        XCTAssert(distance < delta)
        distance = Vec2D.distanceSquared(qCurve2.points[2], Vec2D(fromValues: 80, 32))
        XCTAssert(distance < delta)
        
        let result3 = curve.leftSubcurveAt(0.3)
        XCTAssert(result1 is QuadraticBezier)
        let qCurve3 = result3 as! QuadraticBezier
        distance = Vec2D.distanceSquared(qCurve3.points[0], Vec2D(fromValues: 0, 0))
        XCTAssert(distance < delta)
        distance = Vec2D.distanceSquared(qCurve3.points[1], Vec2D(fromValues: 15, 30))
        XCTAssert(distance < delta)
        distance = Vec2D.distanceSquared(qCurve3.points[2], Vec2D(fromValues: 30, 42))
        XCTAssert(distance < delta)
    }
    
    func testSubcurveBetween() {
        let points = [
            Vec2D(fromValues: 10, 10),
            Vec2D(fromValues: 70, 95),
            Vec2D(fromValues: 25, 20),
            Vec2D(fromValues: 15, 80)
        ]
        let curve = CubicBezier(points)
        
        let res1 = curve.subcurveBetween(0.25, 0.75)
        XCTAssert(res1 is CubicBezier)
        let curve1 = res1 as! CubicBezier
        var d = Vec2D.distance(curve1.points[0], Vec2D(fromValues: 37.5, 48.359375))
        d = Vec2D.distance(curve1.points[1], Vec2D(fromValues: 45.625, 60.078125))
        XCTAssert(d < delta)
        
        let qPoints = [
            Vec2D(fromValues: 70, 95),
            Vec2D(fromValues: 25, 20),
            Vec2D(fromValues: 15, 80)
        ]
        
        let qCurve = QuadraticBezier(qPoints)
        let res2 = qCurve.subcurveBetween(0.8, 0.9)
        XCTAssert(res2 is QuadraticBezier)
        let curve2 = res2 as! QuadraticBezier
        d = Vec2D.distance(curve2.points[0], Vec2D(fromValues: 20.399999618530273, 61.400001525878906))
        XCTAssert(d < delta)
        d = Vec2D.distance(curve2.points[1], Vec2D(fromValues: 18.700000762939453, 64.69999694824219))
        XCTAssert(d < delta)
    }
}
