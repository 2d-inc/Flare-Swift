//
//  trim_path.swift
//  FlareBezier
//
//  Created by Umberto Sonnino on 3/8/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

func trimPath<C: ConcretePath>(_ paths : [PiecewiseBezier<C>], _ startT: Float, _ stopT: Float, _ complement: Bool, _ isSequential: Bool) -> ConcretePath {
    if isSequential {
        return _trimPathSequential(paths, startT, stopT, complement)
    } else {
        return _trimPathSync(paths, startT, stopT, complement)
    }
}

private func _trimPathSync<C: ConcretePath>(_ paths: [PiecewiseBezier<C>], _ startT: Float, _ stopT: Float, _ complement: Bool) -> ConcretePath {
    let result = C.init()
    
    for p in paths {
        let length = p.length
        let trimStart = length * startT
        let trimEnd = length * stopT
        
        if complement {
            if trimStart > 0 {
                _appendPathSegmentSync(p, result, 0.0, 0.0, trimStart)
            }
            if trimEnd < length {
                _appendPathSegmentSync(p, result, 0.0, trimEnd, length)
            }
        } else {
            if trimStart < trimEnd {
                _appendPathSegmentSync(p, result, 0.0, trimStart, trimEnd)
            }
        }
    }
    
    return result
}

private func _trimPathSequential<C: ConcretePath>(_ paths: [PiecewiseBezier<C>], _ startT: Float, _ stopT: Float, _ complement: Bool) -> ConcretePath {
    let result = C.init()
    
    var totalLength: Float = 0
    for p in paths {
        totalLength += p.length
    }
    let trimStart = totalLength * startT
    let trimStop = totalLength * stopT
    var offset: Float = 0.0
    
    if complement {
        if trimStart > 0 {
            offset = _appendPathSegmentSequential(paths, result, offset, 0.0, trimStart)
        }
        if trimStop < totalLength {
            offset = _appendPathSegmentSequential(paths, result, offset, trimStop, totalLength)
        }
    } else {
        if trimStart < trimStop {
            offset = _appendPathSegmentSequential(paths, result, offset, trimStart, trimStop)
        }
    }
    
    return result
}

private func _appendPathSegmentSync<C: ConcretePath>(_ path: PiecewiseBezier<C>, _ to: ConcretePath, _ offset: Float, _ start: Float, _ stop: Float) {
    let nextOffset = offset + path.length
    if start < nextOffset {
        if let extracted = path.extractPath(start-offset, stop-offset) {
            to.addPath(extracted, mat: path.transform)
        }
    }
}

/// offset, start and stop are all relative to the length of the full path.
private func _appendPathSegmentSequential<C: ConcretePath>(_ paths: [PiecewiseBezier<C>], _ to: ConcretePath, _ offset: Float, _ start: Float, _ stop: Float) -> Float {
    var result = offset
    var nextOffset = offset
    
    for p in paths {
        nextOffset = offset + p.length
        if start < nextOffset {
            if let extracted = p.extractPath(start-offset, stop-offset) {
                to.addPath(extracted, mat: p.transform)
            }
            if stop < nextOffset {
                break
            }
        }
        result = nextOffset
    }
    
    return result
}
