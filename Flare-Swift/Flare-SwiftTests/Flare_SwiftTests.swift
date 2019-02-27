//
//  Flare_SwiftTests.swift
//  Flare-SwiftTests
//
//  Created by Umberto Sonnino on 2/11/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import XCTest
@testable import Flare_Swift

class Flare_SwiftTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
//        let projectBundle = Bundle(for: Flare_SwiftTests.self)
//        let fm = FileManager.default
//        guard let path = projectBundle.path(forResource: "Filip", ofType: "flr") else {
//            print("NO PATH? \(fm.currentDirectoryPath)")
//            let documentsURL = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            do {
//                let fileURLs = try fm.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
//                for url in fileURLs {
//                    print("URL: \(url.absoluteString)")
//                }
//            } catch {
//                print("ERROR: ENUMERATING FILES \(documentsURL.path), \(error.localizedDescription)")
//            }
//            return
//        }
//
//        guard let data = fm.contents(atPath: path) else {
//            print("NO DATA??")
//            return
//        }
//
//        flrFileData = data
//
//        print("GOT MAH DATAH! \(String(data: data[0...4], encoding: String.Encoding.utf8) ?? "NO_SIGNATURE")")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testReaderType() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let bundle = Bundle(for: Flare_SwiftTests.self)
        print("CWD: \(bundle.bundlePath)")
        do {
            let urls = try FileManager.default.contentsOfDirectory(atPath: bundle.bundlePath)
            for u in urls {
                print("URL: \(u)")
            }
        } catch {
            print("ERROR: ENUMERATING FILES \(error.localizedDescription)")
        }
        guard let path = bundle.path(forResource: "Circle", ofType: "flr") else {
            return
        }
        
        guard let data = FileManager.default.contents(atPath: path) else {
            print("NO DATA??")
            return
        }
        
        print("GOT MAH DATAH! \(String(data: data[0...4], encoding: String.Encoding.utf8) ?? "NO_SIGNATURE")")
        
        let reader = ReaderFactory.factory(data: data)
        assert(reader is BinaryReader)
    }
    
    func testLoad() {
        let bundle = Bundle(for: Flare_SwiftTests.self)
        guard let path = bundle.path(forResource: "Circle", ofType: "flr") else {
            return
        }
        guard let data = FileManager.default.contents(atPath: path) else {
            print("NO DATA??")
            return
        }
        let f = FlareActor()
        f.loadData(data)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
