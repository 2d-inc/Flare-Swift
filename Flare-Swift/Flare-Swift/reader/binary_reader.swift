//
//  binary_reader.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/14/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class BinaryReader : StreamReader {
    var _raw: [UInt8]
    var _readIndex: Int
    var blockType: Int
    
    required init(data: [UInt8]) {
        _raw = data
        _readIndex = 0
        blockType = 0
    }
    
    static func fromBlock(type: Int, data: [UInt8]) -> BinaryReader {
        let br = BinaryReader(data: data)
        br.blockType = type
        return br
    }
    
    func readNextBlock(blockTypes types: [String : Int]) -> StreamReader? {
        if(isEOF()) {
            return nil
        }
        
        let blockType = Int(readUint8())
        let length = Int(readUint32())
        
        var buffer = Array<UInt8>(repeating: 0, count: length)
        readUint8Array(list: &buffer, length: length, offset: 0)
        return BinaryReader.fromBlock(type: blockType, data: buffer)
    }
    
    func isEOF() -> Bool {
        return _readIndex >= _raw.endIndex
    }
    
    func readUint8Length() -> UInt8 {
        return readUint8()
    }
    
    func readUint16Length() -> UInt16 {
        return readUint16()
    }
    
    func readUint32Length() -> UInt32 {
        return readUint32()
    }
    
    func readUint8(label: String? = nil) -> UInt8 {
        let r = _raw[_readIndex]
        _readIndex += 1
        return r
    }
    
    func readUint8Array(list: inout [UInt8], length: Int, offset: Int, label: String? = nil) {
        let end = offset + length
        for i in offset..<end {
            list[i] = _raw[_readIndex]
            _readIndex += 1
        }
    }
    
    func readInt8(label: String? = nil) -> Int8 {
        let data = _raw[_readIndex]
        let r: Int8 = Int8(data)
        _readIndex += 1
        return r
    }
    
    func readUint16(label: String? = nil) -> UInt16 {
        let r = UInt16(_raw[_readIndex]) | UInt16(_raw[_readIndex+1]) << 8
        _readIndex += 2
        return r
    }
    
    func readUint16Array(ar: inout [UInt16], length: Int, offset: Int, label: String? = nil) {
        let end = offset + length
        for i in offset ..< end {
            ar[i] = UInt16(_raw[_readIndex]) |
                    UInt16(_raw[_readIndex+1]) << 8
            _readIndex += 2
        }
    }
    
    func readInt16(label: String? = nil) -> Int16 {
        return Int16(readUint16())
    }
    
    func readInt32(label: String? = nil) -> Int32 {
        return Int32(bitPattern: readUint32())
    }
    
    func readUint32(label: String? = nil) -> UInt32 {
        let r = UInt32(_raw[_readIndex]) |
                UInt32(_raw[_readIndex+1]) << 8 |
                UInt32(_raw[_readIndex+2]) << 16 |
                UInt32(_raw[_readIndex+3]) << 24
        _readIndex += 4
        return r
    }
    
    func readVersion() -> Int {
        return Int(readUint32())
    }
    
    func readFloat32(label: String? = nil) -> Float32 {
        let bytes = Array(_raw[_readIndex ..< _readIndex+4])
        _readIndex += 4
        var r: Float32 = 0.0
        memcpy(&r, bytes, 4)
        return r
    }
    
    func readFloat32Array(ar: inout [Float32], label: String? = nil) {
        readFloat32ArrayOffset(ar: &ar, length: ar.count, offset: 0)
    }
    
    func readFloat32ArrayOffset(ar: inout [Float32], length: Int, offset: Int, label: String? = nil) {
        let end = offset + length
        for i in offset ..< end {
            ar[i] = readFloat32()
        }
    }
    
    func readFloat64(label: String? = nil) -> Float64 {
        let bytes = Array(_raw[_readIndex ..< _readIndex+8])
        _readIndex += 8
        var r: Float64 = 0.0
        memcpy(&r, bytes, 8)
        return r
    }
    
    func readString(label: String? = nil) -> String {
        let length = Int(readUint32())
        let end = _readIndex + length
        return String(bytes: _raw[_readIndex ..< end], encoding: String.Encoding.utf8)!
        
    }
    
    func readBool(label: String? = nil) -> Bool {
        return readUint8(label: label) == 1
    }
    
    func readId(label: String? = nil) -> Int {
        return Int(readUint16(label: label))
    }
    
    func openArray(label: String? = nil) {}
    
    func closeArray() {}
    
    func openObject(label: String? = nil) {}
    
    func closeObject() {}
    
    var containerType: String {
            return "bin"
    }
    
    
}
