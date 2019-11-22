//
//  stream_reader.swift
//  Flare
//
//  Created by Umberto Sonnino on 2/14/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public protocol StreamReader: class {
    var blockType: Int { get set }
    
    
    func isEOF() -> Bool
    func readNextBlock(blockTypes: [String: Int]) -> StreamReader?
    
    func readUint8Length() -> UInt8
    func readUint16Length() -> UInt16
    func readUint32Length() -> UInt32
    
    func readUint8(label: String?) -> UInt8
    func readUint8Array(list: inout [UInt8], length: Int, offset: Int, label: String?)
    func readInt8(label: String?) -> Int8
    func readUint16(label: String?) -> UInt16
    func readUint16Array(ar: inout [UInt16], length: Int, offset: Int, label: String?)
    func readInt16(label: String?) -> Int16
    func readInt32(label: String?) -> Int32
    func readUint32(label: String?) -> UInt32
    func readVersion() -> Int
    func readFloat32(label: String?) -> Float32
    func readFloat32Array(ar: inout [Float32], label: String?)
    func readFloat32ArrayOffset(ar: inout [Float32], length: Int, offset: Int, label: String?)
    func readFloat64(label: String?) -> Float64
    
    func readString(label: String?) -> String
    
    func readBool(label: String?) -> Bool
    
    func readId(label: String?) -> Int
    
    func readAsset() -> [UInt8]
    
    func openArray(label: String?)
    func closeArray()
    func openObject(label: String?)
    func closeObject()
    
    var containerType: String { get }
}

// Add Factory function
class ReaderFactory {
    static func factory(data: Data) -> StreamReader? {
        let signature = String(data: data[0...4], encoding: String.Encoding.utf8)
        var r: StreamReader? = nil
        if signature == "FLARE" {
            r = BinaryReader(data: Array(data))
            (r as! BinaryReader)._readIndex = 5
        } else {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let jsonObject = [ "container": json ]
                r = JSONReader(data: jsonObject as [String : Any])
            } catch let err {
                print(err)
            }
        }
        return r
    }
}
