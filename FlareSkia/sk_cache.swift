//
//  cache.swift
//  FlareSwift
//
//  Created by Umberto Sonnino on 10/11/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation
import os.log

typealias BundleId = String

// Keeps the mapping between Bundle of resources, and their
// respective cache.
class BundleCache {
    static let storage = BundleCache()
    /// A mapping of loaded Flare assets
    /// This is a cache object only that uses a Bundle ID as Key.
    private var cache = [BundleId: FlareSkCache]()
    private init() {}
    
    // Get a chached Skia Actor, or load it if needed.
    func cachedAsset(bundle: BundleId, filename: String) -> SkCacheAsset? {
        var bundleCache = cache[bundle]
        if bundleCache == nil {
            bundleCache = FlareSkCache()
            cache[bundle] = bundleCache
        }
        if let bCache = bundleCache,
            let asset = bCache.getAsset(filename) {
            bCache.ref(asset)
            return asset
        }
        // Something went wrong
        #warning("TODO: use Result")
        os_log("Cache or asset are nil!", type: .debug)
        return nil
    }
    
    func deref(in bundle: BundleId, for asset: SkCacheAsset) {
        guard let bundleCache = cache[bundle] else {
            os_log("Asset dereferencing from the wrong bundle!", type: .error)
            return
        }
        bundleCache.deref(asset)
    }
}




final class SkCacheAsset: CacheAsset {
    private var _value: FlareSkActor?
    var value: FlareSkActor? { return _value }
    
    override var isAvailable: Bool { return _value != nil }
    
    override init() {
        super.init()
        _value = nil
    }
    
    // Synchronously load the file at the given location.
    override func load(_ file: String) throws {
        #warning("TODO: use Result")
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

    /** TODO: possibly async variants, if needed. */

}

final class FlareSkCache: FlareCache<SkCacheAsset> {
    let doesPrune: Bool = true
    override var isPruningEnabled: Bool { return doesPrune }
    
    override func makeAsset() -> SkCacheAsset {
        return SkCacheAsset()
    }
}
