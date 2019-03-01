//
//  block_types.swift
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/19/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

let BlockTypesMap: [String: Int] = [
    "unknown": BlockTypes.Unknown,
    "nodes": BlockTypes.Components,
    "node": BlockTypes.ActorNode,
    "bone": BlockTypes.ActorBone,
    "rootBone": BlockTypes.ActorRootBone,
    "image": BlockTypes.ActorImage,
    "view": BlockTypes.View,
    "animation": BlockTypes.Animation,
    "animations": BlockTypes.Animations,
    "atlases": BlockTypes.Atlases,
    "atlas": BlockTypes.Atlas,
    "event": BlockTypes.ActorEvent,
    "customInt": BlockTypes.CustomIntProperty,
    "customFloat": BlockTypes.CustomFloatProperty,
    "customString": BlockTypes.CustomStringProperty,
    "customBoolean": BlockTypes.CustomBooleanProperty,
    "rectangleCollider": BlockTypes.ActorColliderRectangle,
    "triangleCollider": BlockTypes.ActorColliderTriangle,
    "circleCollider": BlockTypes.ActorColliderCircle,
    "polygonCollider": BlockTypes.ActorColliderPolygon,
    "lineCollider": BlockTypes.ActorColliderLine,
    "imageSequence": BlockTypes.ActorImageSequence,
    "solo": BlockTypes.ActorNodeSolo,
    "jelly": BlockTypes.JellyComponent,
    "jellyBone": BlockTypes.ActorJellyBone,
    "ikConstraint": BlockTypes.ActorIKConstraint,
    "distanceConstraint": BlockTypes.ActorDistanceConstraint,
    "translationConstraint": BlockTypes.ActorTranslationConstraint,
    "rotationConstraint": BlockTypes.ActorRotationConstraint,
    "scaleConstraint": BlockTypes.ActorScaleConstraint,
    "transformConstraint": BlockTypes.ActorTransformConstraint,
    "shape": BlockTypes.ActorShape,
    "path": BlockTypes.ActorPath,
    "colorFill": BlockTypes.ColorFill,
    "colorStroke": BlockTypes.ColorStroke,
    "gradientFill": BlockTypes.GradientFill,
    "gradientStroke": BlockTypes.GradientStroke,
    "radialGradientFill": BlockTypes.RadialGradientFill,
    "radialGradientStroke": BlockTypes.RadialGradientStroke,
    "ellipse": BlockTypes.ActorEllipse,
    "rectangle": BlockTypes.ActorRectangle,
    "triangle": BlockTypes.ActorTriangle,
    "star": BlockTypes.ActorStar,
    "polygon": BlockTypes.ActorPolygon,
    "artboards": BlockTypes.Artboards,
    "artboard": BlockTypes.ActorArtboard
]

class BlockTypes {
    static let Unknown = 0
    static let Components = 1
    static let ActorNode = 2
    static let ActorBone = 3
    static let ActorRootBone = 4
    static let ActorImage = 5
    static let View = 6
    static let Animation = 7
    static let Animations = 8
    static let Atlases = 9
    static let Atlas = 10
    static let ActorIKTarget = 11
    static let ActorEvent = 12
    static let CustomIntProperty = 13
    static let CustomFloatProperty = 14
    static let CustomStringProperty = 15
    static let CustomBooleanProperty = 16
    static let ActorColliderRectangle = 17
    static let ActorColliderTriangle = 18
    static let ActorColliderCircle = 19
    static let ActorColliderPolygon = 20
    static let ActorColliderLine = 21
    static let ActorImageSequence = 22
    static let ActorNodeSolo = 23
    static let JellyComponent = 28
    static let ActorJellyBone = 29
    static let ActorIKConstraint = 30
    static let ActorDistanceConstraint = 31
    static let ActorTranslationConstraint = 32
    static let ActorRotationConstraint = 33
    static let ActorScaleConstraint = 34
    static let ActorTransformConstraint = 35
    static let ActorShape = 100
    static let ActorPath = 101
    static let ColorFill = 102
    static let ColorStroke = 103
    static let GradientFill = 104
    static let GradientStroke = 105
    static let RadialGradientFill = 106
    static let RadialGradientStroke = 107
    static let ActorEllipse = 108
    static let ActorRectangle = 109
    static let ActorTriangle = 110
    static let ActorStar = 111
    static let ActorPolygon = 112
    static let ActorSkin = 113
    static let ActorArtboard = 114
    static let Artboards = 115
}
