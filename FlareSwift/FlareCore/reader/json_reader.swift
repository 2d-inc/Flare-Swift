//
//  json_reader.swift
//  FlareCore
//
//  Created by Umberto Sonnino on 2/14/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class JSONReader : StreamReader {
    
    var blockType: Int
    var _readObject: Any
    var _context: Array<Any>
    
    required init(data: [String: Any]) {
        blockType = 0
        _readObject = data["container"]!
        _context = []
        _context.insert(_readObject, at: 0)
    }
    
    static func fromBlock(type: Int, data: [String: Any]) -> JSONReader {
        let jr = JSONReader(data: data)
        jr.blockType = type
        return jr
    }
    
    func readNextBlock(blockTypes: [String : Int]) -> StreamReader? {
        if isEOF() {
            return nil
        }
        
        var obj : [String: Any] = [:]
        obj["container"] = self.peek()
        let type = readBlockType(blockTypes)
        let first = _context.first
        if var d = first as? Dictionary<String, Any> {
            d.removeValue(forKey: self.nextKey)
        } else if var arr = first as? Array<Any> {
            arr.remove(at: 0)
        }
        
        return JSONReader.fromBlock(type: type!, data: obj)
    }
    
    private func readBlockType(_ blockTypes: [String: Int]) -> Int? {
        let next = peek()
        var bType: Int?
        
        if let nn = next as? Dictionary<String, Any> {
            let last = self._context.first
            if last is Dictionary<String, Any> {
                bType = blockTypes[self.nextKey]!
            } else if last is Array<Any> {
                // Objects are serialized with "type" property
                let nType = nn["type"] as! String
                bType = blockTypes[nType]!
            }
        } else if next is Array<Any> {
            // Arrays are serialized as "type": [Array]
            bType = blockTypes[self.nextKey]!
        }
        
        return bType
    }
    
    private func peek() -> Any? {
        guard let stream = _context.first else {
            print("peek(): no first element!")
            return nil
        }
        
        var next: Any?
        if let dictionary = stream as? Dictionary<String, Any> {
            next = dictionary[self.nextKey]
        }
        else if let array = stream as? Array<Any> {
            next = array[0]
        }
        return next
    }
    
    private var nextKey: String {
        get {
            guard let d = _context.first else {
                print("nextKey(): no first value")
                return ""
            }
            if let dictionary = d as? Dictionary<String, Any> {
                return dictionary.keys.first!
            } else {
                print("nextKey(): not a Dictionary!")
                return ""
            }
        }
    }
    
    private func readProp<T>(_ label: String?) -> T? {
        guard let l = label else {
            print("readProp(): trying to pass a nil label!")
            return nil
        }
        let head = _context.first
        if var h = head as? Dictionary<String, Any> {
            let prop = h[l] as? T
            h.removeValue(forKey: l)
            return prop
        } else if var h = head as? Array<T> {
            return h.remove(at: 0)
        }
        print("readProp(): failed to look for \(label ?? "NO_PROP_LABEL")")
        return nil
    }
    
    private func readArrayOffset<T>(_ array: inout Array<T>, _ length: Int, _ offset: Int, _ label: String) {
        let ar: Array<T> = readProp(label)!
        
        for i in 0 ..< length {
            array[offset + i] = ar[i]
        }
    }
    
    private func readLength() -> Int {
        return (_context.first as AnyObject).count
    }
    
    func isEOF() -> Bool {
        return _context.count <= 1 && (_readObject as AnyObject).count == 0
    }
    
    func readUint8Length() -> UInt8 {
        return UInt8(readLength())
    }
    
    func readUint16Length() -> UInt16 {
        return UInt16(readLength())
    }
    
    func readUint32Length() -> UInt32 {
        return UInt32(readLength())
    }
    
    func readUint8(label: String?) -> UInt8 {
        let r: UInt8 = readProp(label)!
        return r
    }
    
    func readUint8Array(list: inout [UInt8], length: Int, offset: Int, label: String?) {
        readArrayOffset(&list, length, offset, label!)
    }
    
    func readInt8(label: String?) -> Int8 {
        let r: Int8 = readProp(label)!
        return r
    }
    
    func readUint16(label: String?) -> UInt16 {
        let r: UInt16 = readProp(label)!
        return r
    }
    
    func readUint16Array(ar: inout [UInt16], length: Int, offset: Int, label: String?) {
        readArrayOffset(&ar, length, offset, label!)
    }
    
    func readInt16(label: String?) -> Int16 {
        let r: Int16 = readProp(label)!
        return r
    }
    
    func readInt32(label: String?) -> Int32 {
        let r: Int32 = readProp(label)!
        return r
    }
    
    func readUint32(label: String?) -> UInt32 {
        let r: UInt32 = readProp(label)!
        return r
    }
    
    func readVersion() -> Int {
        let r: Int = readProp("version")!
        return r
    }
    
    func readFloat32(label: String?) -> Float32 {
        let r: Float32 = readProp(label)!
        return r
    }
    
    func readFloat32Array(ar: inout [Float32], label: String?) {
        readArrayOffset(&ar, ar.count, 0, label!)
    }
    
    func readFloat32ArrayOffset(ar: inout [Float32], length: Int, offset: Int, label: String?) {
        readArrayOffset(&ar, ar.count, offset, label!)
    }
    
    func readFloat64(label: String?) -> Float64 {
        let r: Float64 = readProp(label)!
        return r
    }
    
    func readString(label: String?) -> String {
        let r: String = readProp(label)!
        return r
    }
    
    func readBool(label: String?) -> Bool {
        let r: Bool = readProp(label)!
        return r
    }
    
    func readId(label: String?) -> Int {
        let r: Int? = readProp(label)
        return r != nil ? r! + 1 : 0
    }
    
    func readAsset() -> [UInt8] {
        let encodedAsset = readString(label: "data")
        let decodedData = Data(base64Encoded: encodedAsset)!
        return Array<UInt8>(decodedData)
    }
    
    func openArray(label: String?) {
        let r: Array<Any> = readProp(label)!
        _context.insert(r, at: 0)
    }
    
    func closeArray() {
        _context.removeFirst()
    }
    
    func openObject(label: String?) {
        let r: Any = readProp(label)!
        _context.insert(r, at: 0)
    }
    
    func closeObject() {
        _context.removeFirst()
    }
    
    var containerType: String {
        return "json"
    }
}
