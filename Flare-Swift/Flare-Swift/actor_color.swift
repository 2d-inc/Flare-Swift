//
//  actor_color.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/20/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

enum FillRule: UInt8 { case EvenOdd = 0, NonZero }

enum StrokeCap: UInt8 { case Butt = 0, Round, Square }

enum StrokeJoin: UInt8 { case Miter = 0, Round, Bevel }

enum TrimPath: UInt8 { case Off = 0, Sequential, Synced }


class ActorPaint: ActorComponent {
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
    
    internal override init() {
        /* Internal initializer is not visible from outside */
    }
    
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
    
    static func readPaint(_ artboard: ActorArtboard, _ reader: StreamReader, _ paint: ActorPaint) -> ActorPaint {
        _ = ActorComponent.read(artboard, reader, paint)
        paint.opacity = Double(reader.readFloat32(label: "opacity"))
        return paint
    }
}

class ActorColor: ActorPaint {
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
            _color[4] = newValue[3]
            markPaintDirty()
        }
    }
    
    func copyColor(_ component: ActorColor, _ resetArtboard: ActorArtboard) {
        copyPaint(component, resetArtboard)
        _color[0] = component._color[0]
        _color[1] = component._color[1]
        _color[2] = component._color[2]
        _color[4] = component._color[3]
    }
    
    override func onDirty(_ dirt: UInt8) {}
    override func update(dirt: UInt8) {}
    
    static func readColor(_ artboard: ActorArtboard, _ reader: StreamReader, _ color: ActorColor) -> ActorColor {
        _ = ActorPaint.readPaint(artboard, reader, color)
        reader.readFloat32ArrayOffset(ar: &color._color, length: 4, offset: 0, label: "color")
        return color
    }
}

protocol ActorFill: class {
    var _fillRule: FillRule { get set }
    
    
    func copyFill(_ node: ActorFill, _ resetArtboard: ActorArtboard)
    func initializeGraphics()
    
    static func readFill(_ artboard: ActorArtboard, _ reader: StreamReader, _ fill: ActorFill)
}

extension ActorFill {
    var fillRule: FillRule {
        return _fillRule
    }
    
    func copyFill(_ node: ActorFill, _ resetArtboard: ActorArtboard) {
        _fillRule = node._fillRule
    }
    
    static func readFill(_ artboard: ActorArtboard, _ reader: StreamReader, _ fill: ActorFill) {
        let fr = reader.readUint8(label: "fillRule")
        fill._fillRule = FillRule(rawValue: fr)!
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
    var _trimStart: Double? { get set }
    var trimStart: Double? { get set }
    var _trimEnd: Double? { get set }
    var trimEnd: Double? { get set }
    var _trimOffset: Double? { get set }
    var trimOffset: Double? { get set }
    var isTrimmed: Bool { get } // i.e. when _trim != TrimPath.Off
    
    func markPaintDirty()
    func markPathEffectsDirty()
    func copyStroke(_ node: ActorStroke, _ resetArtboard: ActorArtboard)
    func initializeGraphics()
    
    static func readStroke(_ artboard: ActorArtboard, _ reader: StreamReader, _ fill: ActorStroke)
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
    
    var trimStart: Double? {
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
    
    var trimOffset: Double? {
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
    
    var trimEnd: Double? {
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
    
    static func readStroke(_ artboard: ActorArtboard, _ reader: StreamReader, _ stroke: ActorStroke) {
        stroke.width = Double(reader.readFloat32(label: "width"))
        let version = artboard.actor.version
        if version >= 19 {
            let c = reader.readUint8(label: "cap")
            let j = reader.readUint8(label: "join")
            stroke._cap = StrokeCap(rawValue: c)!
            stroke._join = StrokeJoin(rawValue: j)!
            if version >= 20 {
                let t = reader.readUint8(label: "trim")
                stroke._trim = TrimPath(rawValue: t) ?? TrimPath.Off
                if stroke._trim != .Off {
                    stroke._trimStart = Double(reader.readFloat32(label: "start"))
                    stroke._trimEnd = Double(reader.readFloat32(label: "end"))
                    stroke._trimOffset = Double(reader.readFloat32(label: "offset"))
                }
            }
        }
    }
}

class ColorFill: ActorColor, ActorFill {
    var _fillRule: FillRule = .EvenOdd
    
    var fillRule: FillRule {
        return _fillRule
    }
    
    func initializeGraphics() {}
    
    override func completeResolve() {
        super.completeResolve()
        
        if let p = parent as? ActorShape {
            p.addFill(self)
        }
    }
    
}

class ColorStroke: ActorColor, ActorStroke {
    var _width: Double = 1.0
    var _cap: StrokeCap = .Butt
    var _join: StrokeJoin = .Miter
    var _trim: TrimPath = .Off
    var _trimStart: Double?
    var _trimEnd: Double?
    var _trimOffset: Double?
    
    private func copyColorStroke(_ node: ColorStroke, _ resetArtboard: ActorArtboard) {
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
    
    static func read(_ artboard: ActorArtboard, _ reader: StreamReader, _ component: ColorStroke) -> ColorStroke {
        _ = ColorStroke.readColor(artboard, reader, component)
        _ = ColorStroke.readStroke(artboard, reader, component)
        return component
    }
}

class GradientColor: ActorPaint {
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
    
    static func read(_ artboard: ActorArtboard, _ reader: StreamReader, _ component: GradientColor) -> GradientColor {
        _ = ActorPaint.readPaint(artboard, reader, component)
        
        let numStops = Int(reader.readUint8(label: "numColorStops"))
        var stops = Array<Float32>.init(repeating: 0.0, count: numStops * 5)
        reader.readFloat32ArrayOffset(ar: &stops, length: numStops * 5, offset: 0, label: "colorStops")
        component.colorStops = stops
        
        reader.readFloat32ArrayOffset(ar: &component.start.values, length: 2, offset: 0, label: "start")
        reader.readFloat32ArrayOffset(ar: &component.end.values, length: 2, offset: 0, label: "end")
        
        return component
    }
}

class GradientFill: GradientColor, ActorFill {
    var _fillRule: FillRule = .EvenOdd
    
    var fillRule: FillRule {
        return _fillRule
    }
    
    func initializeGraphics() {}
    
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
    
    static func read(_ artboard: ActorArtboard, _ reader: StreamReader, _ component: GradientFill) -> GradientFill {
        _ = GradientColor.read(artboard, reader, component)
        component._fillRule = FillRule(rawValue: reader.readUint8(label: "fillRule"))!
        return component
    }
}

class GradientStroke: GradientColor, ActorStroke {
    var _width: Double = 1.0
    var _cap: StrokeCap = .Butt
    var _join: StrokeJoin = .Miter
    var _trim: TrimPath = .Off
    var _trimStart: Double?
    var _trimEnd: Double?
    var _trimOffset: Double?
    
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
    
    static func read(_ artboard: ActorArtboard, _ reader: StreamReader, _ component: GradientStroke) -> GradientStroke {
        _ = GradientColor.read(artboard, reader, component)
        _ = GradientStroke.readStroke(artboard, reader, component)
        return component
    }
}

class RadialGradientColor: GradientColor {
    var secondaryRadiusScale = 1.0
    
    func copyRadialGradient(_ node: RadialGradientColor, _ resetArtboard: ActorArtboard) {
        self.copyGradient(node, resetArtboard)
        secondaryRadiusScale = node.secondaryRadiusScale
    }
    
    static func read(_ artboard: ActorArtboard, _ reader: StreamReader, _ component: RadialGradientColor) -> RadialGradientColor {
        _ = GradientColor.read(artboard, reader, component)
        component.secondaryRadiusScale = Double(reader.readFloat32(label: "secondaryRadiusScale"))
        return component
    }
}

class RadialGradientFill: RadialGradientColor, ActorFill {
    var _fillRule: FillRule = .EvenOdd
    
    func initializeGraphics() {}
    
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
    
    static func read(_ artboard: ActorArtboard, _ reader: StreamReader, _ component: RadialGradientFill) -> RadialGradientFill {
        _ = RadialGradientColor.read(artboard, reader, component)
        _ = RadialGradientFill.readFill(artboard, reader, component)
        return component
    }
}

class RadialGradientStroke: RadialGradientColor, ActorStroke {
    var _width: Double = 1.0
    var _cap: StrokeCap = .Butt
    var _join: StrokeJoin = .Miter
    var _trim: TrimPath = .Off
    var _trimStart: Double?
    var _trimEnd: Double?
    var _trimOffset: Double?
    
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
    
    static func read(_ artboard: ActorArtboard, _ reader: StreamReader, _ component: RadialGradientStroke) -> RadialGradientStroke {
        _ = RadialGradientColor.read(artboard, reader, component)
        _ = RadialGradientStroke.readStroke(artboard, reader, component)
        return component
    }
}
