//
//  actor_animation.swift
//  Flare
//
//  Created by Umberto Sonnino on 2/14/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public class PropertyAnimation {
    var _type: Int = PropertyTypes.Unknown
    var _keyFrames: Array<KeyFrame>?
    
    var propertyType: Int {
            return _type
    }
    
    var keyFrames: Array<KeyFrame>? {
            return _keyFrames
    }
    
    static func read(reader: StreamReader, component: inout ActorComponent) -> PropertyAnimation? {
        guard let propertyBlock = reader.readNextBlock(blockTypes: PropertyTypesMap) else {
            return nil
        }

        let propertyAnimation = PropertyAnimation()
        let type = propertyBlock.blockType;
        // TODO: try this in Swift
        // Wish there were a way do to this in Dart without having to create my own hash set.
        // if(!Enum.IsDefined(typeof(PropertyTypes), type))
        // {
        //     return null;
        // }
        // else
        // {
        propertyAnimation._type = type;
        
        propertyBlock.openArray(label: "frames");
        let keyFrameCount = Int(propertyBlock.readUint16Length())
        propertyAnimation._keyFrames = []
        var lastKeyFrame: KeyFrame? = nil
        for i in 0 ..< keyFrameCount {
            propertyBlock.openObject(label: "frame");
            guard let keyFrame = keyFrameFactory(type: type, component: component) else {
                return nil
            }
            if !keyFrame.read(propertyBlock) {
                fatalError("Failed to read a KeyFrame! \(type)")
            }
            propertyAnimation._keyFrames!.insert(keyFrame, at: i)
            if let lk = lastKeyFrame {
                lk.setNext(keyFrame);
            }
            lastKeyFrame = keyFrame
            propertyBlock.closeObject();
        }
        propertyBlock.closeArray();
        
        return propertyAnimation;
    }
    
    static func keyFrameFactory(type: Int, component: ActorComponent) ->  KeyFrame? {
        switch type {
        case PropertyTypes.PosX:
            return KeyFramePosX()
        case PropertyTypes.PosY:
            return KeyFramePosY()
        case PropertyTypes.ScaleX:
            return KeyFrameScaleX()
        case PropertyTypes.ScaleY:
            return KeyFrameScaleY()
        case PropertyTypes.Rotation:
            return KeyFrameRotation()
        case PropertyTypes.Opacity:
            return KeyFrameOpacity()
        case PropertyTypes.DrawOrder:
            return KeyFrameDrawOrder()
        case PropertyTypes.Length:
            return KeyFrameLength()
        case PropertyTypes.ImageVertices:
            return KeyFrameImageVertices(component: component)
        case PropertyTypes.ConstraintStrength:
            return KeyFrameConstraintStrength()
        case PropertyTypes.Trigger:
            return KeyFrameTrigger()
        case PropertyTypes.IntProperty:
            return KeyFrameIntProperty()
        case PropertyTypes.FloatProperty:
            return KeyFrameFloatProperty()
        case PropertyTypes.StringProperty:
            return KeyFrameStringProperty()
        case PropertyTypes.BooleanProperty:
            return KeyFrameBooleanProperty()
        case PropertyTypes.CollisionEnabled:
            return KeyFrameCollisionEnabledProperty()
        case PropertyTypes.ActiveChildIndex:
            return KeyFrameActiveChild()
        case PropertyTypes.Sequence:
            return KeyFrameSequence()
        case PropertyTypes.PathVertices:
            return KeyFramePathVertices(component: component)
        case PropertyTypes.FillColor:
            return KeyFrameFillColor()
        case PropertyTypes.FillGradient:
            return KeyFrameGradient()
        case PropertyTypes.StrokeGradient:
            return KeyFrameGradient()
        case PropertyTypes.FillRadial:
            return KeyFrameRadial()
        case PropertyTypes.StrokeRadial:
            return KeyFrameRadial()
        case PropertyTypes.StrokeColor:
            return KeyFrameStrokeColor()
        case PropertyTypes.StrokeWidth:
            return KeyFrameStrokeWidth()
        case PropertyTypes.StrokeOpacity,
             PropertyTypes.FillOpacity:
            return KeyFramePaintOpacity()
        case PropertyTypes.ShapeWidth:
            return KeyFrameShapeWidth()
        case PropertyTypes.ShapeHeight:
            return KeyFrameShapeHeight()
        case PropertyTypes.CornerRadius:
            return KeyFrameCornerRadius()
        case PropertyTypes.InnerRadius:
            return KeyFrameInnerRadius()
        case PropertyTypes.StrokeStart:
            return KeyFrameStrokeStart()
        case PropertyTypes.StrokeEnd:
            return KeyFrameStrokeEnd()
        case PropertyTypes.StrokeOffset:
            return KeyFrameStrokeOffset()
        default:
            return nil
        }
    }
    
    func apply(time: Double, component: ActorComponent, mix: Float) {
        guard let kf = _keyFrames, kf.count > 0 else {
            print("apply(): _keyFrames is nil, or has no elements!")
            return
        }
        
        var idx = 0;
        // Binary find the keyframe index.
        do {
            var mid = 0;
            var element = 0.0;
            var start = 0;
            var end = kf.count - 1;
            
            while (start <= end) {
                mid = ((start + end) >> 1);
                element = kf[mid]._time;
                if (element < time) {
                    start = mid + 1;
                } else if (element > time) {
                    end = mid - 1;
                } else {
                    start = mid;
                    break;
                }
            }
            idx = start;
        }
        
        if (idx == 0) {
            kf[0].apply(component: component, mix: mix);
        } else {
            if (idx < kf.count) {
                let fromFrame = kf[idx - 1];
                let toFrame = kf[idx];
                if (time == toFrame._time) {
                    toFrame.apply(component: component, mix: mix);
                } else {
                    fromFrame.applyInterpolation(component: component, time: time, toFrame: toFrame, mix: mix);
                }
            } else {
                kf[idx - 1].apply(component: component, mix: mix);
            }
        }
    }
}

public class ComponentAnimation {
    var _componentIndex: Int = -1
    var _properties: Array<PropertyAnimation>?
    
    public var componentIndex: Int {
            return _componentIndex
    }
    
    public var properties: Array<PropertyAnimation>? {
            return _properties
    }
    
    static func read(reader: StreamReader, components: inout Array<ActorComponent?>) -> ComponentAnimation {
        reader.openObject(label: "component");
        let componentAnimation = ComponentAnimation();
    
        componentAnimation._componentIndex = reader.readId(label: "component");
        let numProperties = Int(reader.readUint16Length())
        componentAnimation._properties = Array<PropertyAnimation>()

        for i in 0 ..< numProperties {
            if var c = components[componentAnimation._componentIndex] {
                let pa = PropertyAnimation.read(reader: reader, component: &c)
                componentAnimation._properties!.insert(pa!, at: i)
            }
        }
        reader.closeObject();
    
        return componentAnimation;
    }
    
    func apply(time: Double, components: Array<ActorComponent>, mix: Float) {
        guard let p = _properties else {
            print("apply(): nil _properties")
            return
        }
        for propertyAnimation in p {
            propertyAnimation.apply(time: time, component: components[_componentIndex], mix: mix)
        }
    }
}

class AnimationEventArgs {
    var _name: String
    var _component: ActorComponent
    var _propertyType: Int
    var _keyFrameTime: Double
    var _elapsedTime: Double
    
    init(name: String, component: ActorComponent, type: Int, keyframeTime: Double, elapsedTime: Double) {
        _name = name;
        _component = component;
        _propertyType = type;
        _keyFrameTime = keyframeTime;
        _elapsedTime = elapsedTime;
    }
    
    var name: String {
            return _name
    }
    
    var component: ActorComponent {
            return _component
    }
    
    var propertyType: Int {
            return _propertyType;
    }
    
    var keyFrameTime: Double {
        return _keyFrameTime
    }
    
    var elapsedTime: Double {
        return _elapsedTime
    }
}

public class ActorAnimation {
    var _name = "Unnamed"
    var _fps = 0
    var _duration = 0.0
    var _isLooping = false
    var _components: Array<ComponentAnimation>?
    var _triggerComponents: Array<ComponentAnimation>?
    
    public var name: String{
        return _name
    }
    
    public var isLooping: Bool {
        return _isLooping
    }
    
    public var duration: Double {
        return _duration
    }
    
    public var animatedComponents: Array<ComponentAnimation>? {
        return _components
    }
    
    func triggerEvents(components: Array<ActorComponent>, fromTime: Double, toTime: Double, triggerEvents: inout Array<AnimationEventArgs> ) {
        guard let tc = _triggerComponents else {
            print("triggerEvents(): no trigger components??")
            return
        }

        for i in 0 ..< tc.count {
            let keyedComponent = tc[i];
            for property in keyedComponent.properties! {
                switch (property.propertyType) {
                    case PropertyTypes.Trigger:
                        let keyFrames = property.keyFrames!
                        
                        let kfl = keyFrames.count
                        if kfl == 0 {
                            continue
                        }
                        
                        var idx = 0
                        // Binary find the keyframe index.
                        do {
                            var mid = 0;
                            var element = 0.0;
                            var start = 0;
                            var end = kfl - 1;
                            
                            while (start <= end) {
                                mid = ((start + end) >> 1);
                                element = keyFrames[mid]._time;
                                if (element < toTime) {
                                    start = mid + 1;
                                } else if (element > toTime) {
                                    end = mid - 1;
                                } else {
                                    start = mid;
                                    break;
                                }
                            }
                            
                            idx = start;
                        }
                        
                        if (idx == 0) {
                            if (kfl > 0 && keyFrames[0]._time == toTime) {
                                let component = components[keyedComponent.componentIndex];
                                triggerEvents.append(AnimationEventArgs(
                                    name: component.name,
                                    component: component,
                                    type: property.propertyType,
                                    keyframeTime: toTime,
                                    elapsedTime: 0.0));
                            }
                        } else {
                            for k in stride(from: idx - 1, through: 0, by: -1) {
                                let frame = keyFrames[k];
                            
                                if (frame._time > fromTime) {
                                    let component = components[keyedComponent.componentIndex];
                                    triggerEvents.append(AnimationEventArgs(
                                        name: component.name,
                                        component: component,
                                        type: property.propertyType,
                                        keyframeTime: frame._time,
                                        elapsedTime: toTime - frame._time));
                                } else {
                                    break;
                                }
                            }
                        }
                        break;
                default:
                    break;
                }
            }
        }
    }
    
    public func apply(time: Double, artboard: ActorArtboard, mix: Float) {
        guard let components = _components else {
            print("apply(): no components??")
            return
        }
        for componentAnimation in components {
            componentAnimation.apply(time: time, components: artboard.components! as! Array<ActorComponent>, mix: mix);
        }
    }
    
    static func read(reader: StreamReader, components: inout Array<ActorComponent?>) -> ActorAnimation {
        let animation = ActorAnimation();
        animation._name = reader.readString(label: "name")
        animation._fps = Int(reader.readUint8(label: "fps"))
        animation._duration = Double(reader.readFloat32(label: "duration"))
        animation._isLooping = reader.readBool(label: "isLooping");
    
        reader.openArray(label: "keyed");
        let numKeyedComponents = Int(reader.readUint16Length())
    
        // We distinguish between animated and triggered components as ActorEvents are currently only used to trigger events and don't need
        // the full animation cycle. This lets them optimize them out of the regular animation cycle.
        var animatedComponentCount = 0;
        var triggerComponentCount = 0;
    
        var animatedComponents = [ComponentAnimation]()

        for i in 0 ..< numKeyedComponents {
            let componentAnimation = ComponentAnimation.read(reader: reader, components: &components);
            animatedComponents.insert(componentAnimation, at: i)
            let actorComponent = components[componentAnimation.componentIndex];
            if (actorComponent is ActorEvent) {
                triggerComponentCount += 1
            } else {
                animatedComponentCount += 1
            }
        }
        reader.closeArray();
    
        animation._components = []
        animation._triggerComponents = []
    
        // Put them in their respective lists.
        var animatedComponentIndex = 0;
        var triggerComponentIndex = 0;
        for i in 0 ..< numKeyedComponents {
            let componentAnimation = animatedComponents[i];
            let actorComponent = components[componentAnimation.componentIndex];
            if (actorComponent is ActorEvent) {
                animation._triggerComponents!.insert(componentAnimation, at: triggerComponentIndex)
                triggerComponentIndex += 1
            } else {
                animation._components!.insert(componentAnimation, at: animatedComponentIndex)
                animatedComponentIndex += 1
            }
        }
    
        return animation;
    }
}
