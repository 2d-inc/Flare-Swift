//
//  actor_color.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/20/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public enum FillRule: UInt8 { case EvenOdd = 0, NonZero }
public enum StrokeCap: UInt8 { case Butt = 0, Round, Square }
public enum StrokeJoin: UInt8 { case Miter = 0, Round, Bevel }
public enum TrimPath: UInt8 { case Off = 0, Sequential, Synced }


public class ActorPaint: ActorComponent {
    private var _opacity = 1.0
    var opacity: Double {
        get {
            return _opacity
        }
        set {
            if newValue != _opacity {
                _opacity = newValue
                markPaintDirty()
            }
        }
    }
    
    internal override init() {}
    
    var shape: ActorShape {
        return self.parent as! ActorShape
    }
    
    func copyPaint(_ component: ActorPaint, _ resetArtboard: ActorArtboard) {
        copyComponent(component, resetArtboard)
        opacity = component.opacity
    }
    
    func markPaintDirty() {
        _ = artboard?.addDirt(self, value: DirtyFlags.PaintDirty, recurse: false)
    }
    
    override func completeResolve() {
        _ = artboard?.addDependency(self, parent!)
    }
    
    func readPaint(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readComponent(artboard, reader)
        self.opacity = Double(reader.readFloat32(label: "opacity"))
    }
}

public class ActorColor: ActorPaint {
    private var _color = [Float32].init(repeating: 0.0, count: 4)
    
    var color: [Float32] {
        get {
            return _color
        }
        set {
            if newValue.count != 4 {
                return
            }
            _color[0] = newValue[0]
            _color[1] = newValue[1]
            _color[2] = newValue[2]
            _color[3] = newValue[3]
            markPaintDirty()
        }
    }
    
    func copyColor(_ component: ActorColor, _ resetArtboard: ActorArtboard) {
        copyPaint(component, resetArtboard)
        _color[0] = component._color[0]
        _color[1] = component._color[1]
        _color[2] = component._color[2]
        _color[3] = component._color[3]
    }
    
    override func onDirty(_ dirt: UInt8) {}
    override func update(dirt: UInt8) {}
    
    func readColor(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readPaint(artboard, reader)
        reader.readFloat32ArrayOffset(ar: &self._color, length: 4, offset: 0, label: "color")
    }
}

public protocol ActorFill: class {
    var _fillRule: FillRule { get set }
    
    
    func copyFill(_ node: ActorFill, _ resetArtboard: ActorArtboard)
    func initializeGraphics()
    
    func readFill(_ artboard: ActorArtboard, _ reader: StreamReader)
}

public extension ActorFill {
    var fillRule: FillRule {
        return _fillRule
    }
    
    func copyFill(_ node: ActorFill, _ resetArtboard: ActorArtboard) {
        _fillRule = node._fillRule
    }
    
    func readFill(_ artboard: ActorArtboard, _ reader: StreamReader) {
        let fr = reader.readUint8(label: "fillRule")
        self._fillRule = FillRule(rawValue: fr)!
    }
}

protocol ActorStroke: class {
    var _width: Double { get set }
    var width: Double { get set }
    var _cap: StrokeCap { get set }
    var _join: StrokeJoin { get set }
    var cap: StrokeCap { get }
    var join: StrokeJoin { get }
    var _trim: TrimPath { get set }
    var _trimStart: Double { get set }
    var trimStart: Double { get set }
    var _trimEnd: Double { get set }
    var trimEnd: Double { get set }
    var _trimOffset: Double { get set }
    var trimOffset: Double { get set }
    var isTrimmed: Bool { get } // i.e. when _trim != TrimPath.Off
    
    func markPaintDirty()
    func markPathEffectsDirty()
    func copyStroke(_ node: ActorStroke, _ resetArtboard: ActorArtboard)
    func initializeGraphics()
    
    func readStroke(_ artboard: ActorArtboard, _ reader: StreamReader)
}

extension ActorStroke {
    
    var width: Double {
        get {
            return _width
        }
        set {
            if newValue != _width {
                _width = newValue
                markPaintDirty()
            }
        }
    }
    
    var cap: StrokeCap {
        return _cap
    }
    
    var join: StrokeJoin {
        return _join
    }
    
    var trimStart: Double {
        get {
            return _trimStart
        }
        set {
            if newValue != _trimStart {
                _trimStart = newValue
                markPathEffectsDirty()
            }
        }
    }
    
    func copyStroke(_ node: ActorStroke, _ resetArtboard: ActorArtboard) {
        width = node.width
        _cap = node._cap
        _join = node._join
    }
    
    var trimOffset: Double {
        get {
            return _trimOffset
        }
        set {
            if newValue != _trimOffset {
                _trimOffset = newValue
                markPathEffectsDirty()
            }
        }

    }
    
    var isTrimmed: Bool {
        return _trim != .Off
    }
    
    var trimEnd: Double {
        get {
            return _trimEnd
        }
        set {
            if newValue != _trimEnd {
                _trimEnd = newValue
                markPathEffectsDirty()
            }
        }

    }
    
    func readStroke(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.width = Double(reader.readFloat32(label: "width"))
        let version = artboard.actor.version
        if version >= 19 {
            let c = reader.readUint8(label: "cap")
            let j = reader.readUint8(label: "join")
            self._cap = StrokeCap(rawValue: c)!
            self._join = StrokeJoin(rawValue: j)!
            if version >= 20 {
                let t = reader.readUint8(label: "trim")
                self._trim = TrimPath(rawValue: t) ?? TrimPath.Off
                if self._trim != .Off {
                    self._trimStart = Double(reader.readFloat32(label: "start"))
                    self._trimEnd = Double(reader.readFloat32(label: "end"))
                    self._trimOffset = Double(reader.readFloat32(label: "offset"))
                }
            }
        }
    }
}

public class ColorFill: ActorColor, ActorFill {
    public var _fillRule: FillRule = .EvenOdd
    
    public func initializeGraphics() {}
    
    override func completeResolve() {
        super.completeResolve()
        
        if let p = parent as? ActorShape {
            p.addFill(self)
        }
    }
    
    func copyColorFill(_ node: ColorFill, _ resetArtboard: ActorArtboard) {
        copyColor(node, resetArtboard)
        copyFill(node, resetArtboard)
    }
    
    func readColorFill(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readColor(artboard, reader)
        self.readFill(artboard, reader)
    }
}

public class ColorStroke: ActorColor, ActorStroke {
    var _width: Double = 1.0
    var _cap: StrokeCap = .Butt
    var _join: StrokeJoin = .Miter
    var _trim: TrimPath = .Off
    var _trimStart: Double = 0.0
    var _trimEnd: Double = 0.0
    var _trimOffset: Double = 0.0
    
    func copyColorStroke(_ node: ColorStroke, _ resetArtboard: ActorArtboard) {
        self.copyColor(node, resetArtboard)
        self.copyStroke(node, resetArtboard)
    }
    
    override func completeResolve() {
        super.completeResolve()
        if let parentShape = self.parent as? ActorShape {
            parentShape.addStroke(self)
        }
    }
    
    func markPathEffectsDirty() {}
    
    func initializeGraphics() {}
    
    func readColorStroke(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readColor(artboard, reader)
        self.readStroke(artboard, reader)
    }
}

public class GradientColor: ActorPaint {
    var colorStops = Array<Float32>(repeating: 0.0, count: 10)
    private(set) var start = Vec2D()
    private(set) var end = Vec2D()
    private(set) var renderStart = Vec2D()
    private(set) var renderEnd = Vec2D()
    private var _opacity = 1.0
    
    func copyGradient(_ node: GradientColor, _ resetArtboard: ActorArtboard) {
        copyPaint(node, resetArtboard)
//        _colorStops = Float32List.fromList(node._colorStops)
        colorStops = node.colorStops
        
        // TODO: test if duplicated properly!
        let cs0 = colorStops[0]
        colorStops[0] = 42
        if node.colorStops[0] == 42 {
            print("SOMETHING IS WRONG HERE!")
        }
        print("CHECK COLOR STOPS: \(colorStops), \(node.colorStops)")
        colorStops[0] = cs0
        // === TODO: REMOVE
        
        Vec2D.copy(start, node.start)
        Vec2D.copy(end, node.end)
        opacity = node.opacity
    }
    
    override func onDirty(_ dirt: UInt8) {}
    override func update(dirt: UInt8) {
        let shape = self.parent as! ActorShape
        let world = shape.worldTransform
        _ = Vec2D.transformMat2D(renderStart, start, world)
        _ = Vec2D.transformMat2D(renderEnd, end, world)
    }
    
    func readGradientColor(_ artboard: ActorArtboard, _ reader: StreamReader) {
//        _ = ActorPaint.readPaint(artboard, reader, component)
        self.readPaint(artboard, reader)
        
        let numStops = Int(reader.readUint8(label: "numColorStops"))
        var stops = Array<Float32>.init(repeating: 0.0, count: numStops * 5)
        reader.readFloat32ArrayOffset(ar: &stops, length: numStops * 5, offset: 0, label: "colorStops")
        self.colorStops = stops
        
        reader.readFloat32ArrayOffset(ar: &self.start.values, length: 2, offset: 0, label: "start")
        reader.readFloat32ArrayOffset(ar: &self.end.values, length: 2, offset: 0, label: "end")
    }
}

public class GradientFill: GradientColor, ActorFill {
    public var _fillRule: FillRule = .EvenOdd
    
    public func initializeGraphics() {}
    
    func copyGradientFill(_ node: GradientFill, _ resetArtboard: ActorArtboard) {
        copyGradient(node, resetArtboard)
        copyFill(node, resetArtboard)
    }
    
    override func completeResolve() {
        super.completeResolve()
        if let parentShape = self.parent as? ActorShape {
            parentShape.addFill(self)
        }
    }
    
    func readGradientFill(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readGradientColor(artboard, reader)
        self._fillRule = FillRule(rawValue: reader.readUint8(label: "fillRule"))!
    }
}

public class GradientStroke: GradientColor, ActorStroke {
    var _width: Double = 1.0
    var _cap: StrokeCap = .Butt
    var _join: StrokeJoin = .Miter
    var _trim: TrimPath = .Off
    var _trimStart: Double = 0.0
    var _trimEnd: Double = 0.0
    var _trimOffset: Double = 0.0
    
    func markPathEffectsDirty() {}
    
    func initializeGraphics() {}
    
    func copyGradientStroke(_ node: GradientStroke, _ resetArtboard: ActorArtboard) {
        copyGradient(node, resetArtboard)
        copyStroke(node, resetArtboard)
    }
    
    override func completeResolve() {
        super.completeResolve()
        if let parentShape = self.parent as? ActorShape {
            parentShape.addStroke(self)
        }
    }
    
    func readGradientStroke(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readGradientColor(artboard, reader)
        self.readStroke(artboard, reader)
    }
}

public class RadialGradientColor: GradientColor {
    var secondaryRadiusScale = 1.0
    
    func copyRadialGradient(_ node: RadialGradientColor, _ resetArtboard: ActorArtboard) {
        self.copyGradient(node, resetArtboard)
        secondaryRadiusScale = node.secondaryRadiusScale
    }
    
    func readRadialGradientColor(_ artboard: ActorArtboard, _ reader: StreamReader) {
//        _ = GradientColor.read(artboard, reader, component)
        self.readGradientColor(artboard, reader)
        self.secondaryRadiusScale = Double(reader.readFloat32(label: "secondaryRadiusScale"))
    }
}

public class RadialGradientFill: RadialGradientColor, ActorFill {
    public var _fillRule: FillRule = .EvenOdd
    
    public func initializeGraphics() {}
    
    func copyRadialFill(_ node: RadialGradientFill, _ resetArtboard: ActorArtboard) {
        copyRadialGradient(node, resetArtboard)
        copyFill(node, resetArtboard)
    }
    
    override func completeResolve() {
        super.completeResolve()
        
        if let parentShape = parent as? ActorShape {
            parentShape.addFill(self)
        }
    }
    
    func readRadialGradientFill(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readGradientColor(artboard, reader)
        self.readFill(artboard, reader)
    }
}

public class RadialGradientStroke: RadialGradientColor, ActorStroke {
    var _width: Double = 1.0
    var _cap: StrokeCap = .Butt
    var _join: StrokeJoin = .Miter
    var _trim: TrimPath = .Off
    var _trimStart: Double = 0.0
    var _trimEnd: Double = 0.0
    var _trimOffset: Double = 0.0
    
    func markPathEffectsDirty() {}
    func initializeGraphics() {}
    
    func copyRadialStroke(_ node: RadialGradientStroke, _ resetArtboard: ActorArtboard) {
        copyRadialGradient(node, resetArtboard)
        copyStroke(node, resetArtboard)
    }
    
    override func completeResolve() {
        super.completeResolve()
        
        if let parentShape = parent as? ActorShape {
            parentShape.addStroke(self)
        }
    }
    
    func readRadialGradientStroke(_ artboard: ActorArtboard, _ reader: StreamReader) {
        self.readRadialGradientColor(artboard, reader)
        self.readStroke(artboard, reader)
    }
}
