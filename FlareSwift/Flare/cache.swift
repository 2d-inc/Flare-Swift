//
//  cache.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 10/14/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class FlareCache<T: CacheAsset> {
    var assets = Dictionary<String, T>()
    var toPrune = Set<T>()
    var isPruningEnabled: Bool { return true }
    var pruneTimer: Timer?
    
    let pruneDelay: Double = 2.0
    
    @objc private func prune() {
        for asset in self.toPrune {
            for (cachedKey, cachedValue) in self.assets {
                if cachedValue == asset {
                    self.assets.removeValue(forKey: cachedKey)
                }
            }
        }
        self.toPrune.removeAll()
        pruneTimer = nil
    }
    
    func makeAsset() -> T {
        return CacheAsset() as! T
    }
    
    func drop(_ asset: T) {
        toPrune.insert(asset)
        
        // Avoid firing multiple times.
        pruneTimer?.invalidate()
        if isPruningEnabled {
            pruneTimer = Timer.scheduledTimer(timeInterval: pruneDelay, target: self, selector: #selector(prune), userInfo: nil, repeats: false)
        }
    }
    
    func hold(_ asset: T) {
        toPrune.remove(asset)
    }
    
    func getAsset(_ filename: String) -> T? {
        if let v = assets[filename] {
            if !v.isAvailable {
                do {
                    try v.load(filename, cache: self as! FlareCache<CacheAsset>)
                } catch {
                    print("Couldn't load \(filename)")
                }
            }
            return v
        }
        
        if filename.lastIndex(of: ".") != nil {
            let asset = makeAsset()
            assets[filename] = asset
            do {
                try asset.load(filename, cache: self as! FlareCache<CacheAsset>)
            } catch {
                print("Couldn't load \(filename)")
            }
            return asset
        }
        
        return nil
    }

    subscript(key: String) -> T? {
        get { return getAsset(key) }
        set {
            guard let value = newValue else {
                // If setting nil, remove the element
                assets.removeValue(forKey: key)
                return
            }
            assets[key] = value
        }
    }
}

/// Base class for an Asset in Cache.
/// Meant to be extended.
class CacheAsset: Hashable {
    var cache: FlareCache<CacheAsset>!
    internal var refCount = 0
    
    var isAvailable: Bool {
        return false
    }
    
    init() {}
    
    /// Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
    
    static func ==(lhs: CacheAsset, rhs: CacheAsset) -> Bool {
        return lhs === rhs
    }
    ///
    
    func ref() {
        refCount += 1
        if refCount == 1 {
            cache.hold(self)
        }
    }
    
    func deref() {
        refCount -= 1
        if refCount <= 0 {
            cache.drop(self)
        }
    }
    
    func load(_ file: String, cache: FlareCache<CacheAsset>) throws {
        self.cache = cache
    }
    
    internal enum LoadError: Error {
        case FileNotFound
    }
}
