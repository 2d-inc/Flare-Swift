//
//  property_types.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/14/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

class PropertyTypes {
    static let Unknown = 0
    static let PosX = 1
    static let PosY = 2
    static let ScaleX = 3
    static let ScaleY = 4
    static let Rotation = 5
    static let Opacity = 6
    static let DrawOrder = 7
    static let Length = 8
    static let ImageVertices = 9
    static let ConstraintStrength = 10
    static let Trigger = 11
    static let IntProperty = 12
    static let FloatProperty = 13
    static let StringProperty = 14
    static let BooleanProperty = 15
    static let CollisionEnabled = 16
    static let Sequence = 17
    static let ActiveChildIndex = 18
    static let PathVertices = 19
    static let FillColor = 20
    static let FillGradient = 21
    static let FillRadial = 22
    static let StrokeColor = 23
    static let StrokeGradient = 24
    static let StrokeRadial = 25
    static let StrokeWidth = 26
    static let StrokeOpacity = 27
    static let FillOpacity = 28
    static let ShapeWidth = 29
    static let ShapeHeight = 30
    static let CornerRadius = 31
    static let InnerRadius = 32
    static let StrokeStart = 33
    static let StrokeEnd = 34
    static let StrokeOffset = 35
}

let PropertyTypesMap = [
    "unknown": PropertyTypes.Unknown,
    "posX": PropertyTypes.PosX,
    "posY": PropertyTypes.PosY,
    "scaleX": PropertyTypes.ScaleX,
    "scaleY": PropertyTypes.ScaleY,
    "rotation": PropertyTypes.Rotation,
    "opacity": PropertyTypes.Opacity,
    "drawOrder": PropertyTypes.DrawOrder,
    "length": PropertyTypes.Length,
    "vertices": PropertyTypes.ImageVertices,
    "strength": PropertyTypes.ConstraintStrength,
    "trigger": PropertyTypes.Trigger,
    "intValue": PropertyTypes.IntProperty,
    "floatValue": PropertyTypes.FloatProperty,
    "stringValue": PropertyTypes.StringProperty,
    "boolValue": PropertyTypes.BooleanProperty,
    "isCollisionEnabled": PropertyTypes.CollisionEnabled,
    "sequence": PropertyTypes.Sequence,
    "activeChild": PropertyTypes.ActiveChildIndex,
    "pathVertices": PropertyTypes.PathVertices,
    "fillColor": PropertyTypes.FillColor,
    "fillGradient": PropertyTypes.FillGradient,
    "fillRadial": PropertyTypes.FillRadial,
    "strokeColor": PropertyTypes.StrokeColor,
    "strokeGradient": PropertyTypes.StrokeGradient,
    "strokeRadial": PropertyTypes.StrokeRadial,
    "strokeWidth": PropertyTypes.StrokeWidth,
    "strokeOpacity": PropertyTypes.StrokeOpacity,
    "fillOpacity": PropertyTypes.FillOpacity,
    "width": PropertyTypes.ShapeWidth,
    "height": PropertyTypes.ShapeHeight,
    "cornerRadius": PropertyTypes.CornerRadius,
    "innerRadius": PropertyTypes.InnerRadius,
    "strokeStart": PropertyTypes.StrokeStart,
    "strokeEnd": PropertyTypes.StrokeEnd,
    "strokeOffset": PropertyTypes.StrokeOffset,
]
