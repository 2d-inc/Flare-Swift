//
//  cache.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 10/11/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

typealias BundleId = String

/// A mapping of loaded Flare assets
/// This is a cache object only that uses a Bundle ID as Key.
fileprivate var cache = [BundleId: FlareSkCache]()

// Get a chached Skia Actor, or load it if needed.
func cachedActor(bundle: BundleId, filename: String) -> SkCacheAsset? {
    var bundleCache = cache[bundle]
    if bundleCache == nil {
        bundleCache = FlareSkCache()
        cache[bundle] = bundleCache
    }
    return bundleCache?.getAsset(filename)
}


final class SkCacheAsset: CacheAsset {
    private var _value: FlareSkActor?
    var value: FlareSkActor? { return _value }
    
    override init() { _value = nil }
    
    // Synchronously load the file at the given location.
    override func load(_ file: String, cache: FlareCache<CacheAsset>) throws {
        try super.load(file, cache: cache)
        if let dotIndex = file.lastIndex(of: ".") {
            let filename = String(file.prefix(upTo: dotIndex))
            let typeIndex = file.index(after: dotIndex)
            let filetype = String(file.suffix(from: typeIndex))
            if let path = Bundle.main.path(forResource: filename, ofType: filetype) {
                if let data = FileManager.default.contents(atPath: path) {
                    self._value = FlareSkActor()
                    self._value?.load(data: data)
                }
            }
        }
        
        if !isAvailable {
            throw LoadError.FileNotFound
        }
    }
    /**
     TODO: possibly async variants, if needed.
     */
}

final class FlareSkCache: FlareCache<SkCacheAsset> {
    let doesPrune: Bool = true
    override var isPruningEnabled: Bool { return doesPrune }
    
    override func makeAsset() -> SkCacheAsset {
        return SkCacheAsset()
    }
}
