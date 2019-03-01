//
//  actor_artboard
//  Flare-Swift
//
//  Created by Umberto Sonnino on 2/12/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

import Foundation

public class ActorArtboard {
    private var _flags = ActorFlags.IsDrawOrderDirty | ActorFlags.IsVertexDeformDirty
    
    private var _drawableNodeCount = 0
    public var drawNodeCount: Int {
        get {
            return self._drawableNodeCount
        }
    }
    
    private var _nodeCount = 0
    public var nodeCount: Int{
        get {
            return self._nodeCount
        }
    }
    
    private var _dirtDepth = 0
    private var _root : ActorNode?
    public var root: ActorNode? {
        get {
            return self._root
        }
    }
    
    private var _components : [ActorComponent?]?
    public var components: [ActorComponent?]? {
        get {
            return self._components
        }
    }
    public var componentCount : Int {
        get {
            return _components?.count ?? 0
        }
    }
    
    private var _nodes : [ActorNode?]?
    public var nodes: [ActorNode?]? {
        get {
            return self._nodes
        }
    }
    
    private var _drawableNodes = [ActorDrawable]()
    public var drawableNodes: [ActorDrawable] {
        get {
            return self._drawableNodes
        }
    }

    private var _animations : [ActorAnimation]?
    public var animations : [ActorAnimation]? {
        get {
            return self._animations
        }
    }
    
    private var _dependencyOrder : [ActorComponent]?
    
    private var _actor : Actor
    public var actor : Actor {
        get {
            return self._actor
        }
    }
    
    private var _name : String
    public var name : String {
        get {
            return self._name
        }
    }
    
    private var _translation = Vec2D()
    public var translation : Vec2D {
        get {
            return self._translation
        }
    }
    
    private var _origin = Vec2D()
    public var origin: Vec2D {
        get {
            return self._origin
        }
    }
    
    private var _width = 0.0
    public var width: Double {
        get {
            return self._width
        }
    }
    
    private var _height = 0.0
    public var height: Double {
        get {
            return self._height
        }
    }

    private var _modulateOpacity = 1.0
    public var modulateOpacity: Double {
        get {
            return self._modulateOpacity
        }
        set {
            self._modulateOpacity = newValue
            for drawable in _drawableNodes {
                let _ =
                    addDirt((drawable as! ActorComponent), value: DirtyFlags.PaintDirty, recurse: true)
            }
        }
    }
    
    private var _clipContents = true
    public var clipContents: Bool {
        get {
            return self._clipContents
        }
    }
    
    private var _color = [Float32](repeating: 0.0, count: 4)

    private var _overrideColor : [Float32]?
    public var overrideColor: [Float32]? {
        get {
            return self._overrideColor
        }
        set {
            self._overrideColor = newValue
            for drawable in self._drawableNodes {
                let _ =
                    addDirt((drawable as! ActorComponent), value: DirtyFlags.PaintDirty, recurse: true)
            }
        }
    }
    
    subscript(index: Int) -> ActorComponent? {
        get {
            return _components?[index] ?? nil
        }
    }
    
    public init(actor: Actor) {
        _name = ""
        _actor = actor
        _root = ActorNode(withArtboard: self)
    }
    
    func addDependency(_ a: ActorComponent, _ b: ActorComponent) -> Bool {
        if b.dependents == nil {
            b.dependents = [ActorComponent]()
        }
        if b.dependents!.contains(a) {
            return false
        }
        b.dependents!.append(a)
        return true
    }
    
    func sortDependencies() {
        let sorter = DependencySorter()
        _dependencyOrder = sorter.sort(_root!)
        var graphOrder = 0
        if let depOr = _dependencyOrder {
            for component in depOr {
                graphOrder += 1
                component.graphOrder = graphOrder
                component.dirtMask = 255
            }
        }
        _flags |= ActorFlags.IsDirty
    }
    
    func addDirt(_ component: ActorComponent, value: UInt8, recurse: Bool) -> Bool {
        if (component.dirtMask & value) == value {
            // Already marked.
            return false
        }
    
        // Make sure dirt is set before calling anything that can set more dirt.
        let dirt = component.dirtMask | value
        component.dirtMask = dirt
    
        _flags |= ActorFlags.IsDirty
    
        component.onDirty(dirt)
    
        // If the order of this component is less than the current dirt depth, update the dirt depth
        // so that the update loop can break out early and re-run (something up the tree is dirty).
        if (component.graphOrder < _dirtDepth) {
            _dirtDepth = component.graphOrder
        }
        if (!recurse) {
            return true
        }
        
        if let dependents = component.dependents {
            for d in dependents {
                let _ = addDirt(d, value: value, recurse: recurse)
            }
        }
    
        return true
    }
    
    func getAnimation(name: String) -> ActorAnimation? {
        guard let anims = _animations else {
            print("getAnimation(\(name)): animations array is nil!")
            return nil
        }
        for a in anims {
            if a.name == name {
                return a
            }
        }
        return nil
    }
    
    func getNode(name: String) -> ActorNode? {
        for node in _nodes! {
            if node != nil && node!.name == name {
                return node
            }
        }
        return nil
    }
    
    func markDrawOrderDirty() {
        _flags |= ActorFlags.IsDrawOrderDirty
    }
    
    var isVertexDeformDirty: Bool {
        get {
            return (_flags & ActorFlags.IsVertexDeformDirty) != 0x00
        }
    }
    
    public func makeInstance() -> ActorArtboard {
        let artboardInstance = ActorArtboard(actor: _actor)
        artboardInstance.copyArtboard(self)
        return artboardInstance
    }
    
    func copyArtboard(_ artboard: ActorArtboard) {
        _name = artboard._name;
        Vec2D.copy(_translation, artboard._translation);
        _width = artboard._width;
        _height = artboard._height;
        Vec2D.copy(_origin, artboard._origin);
        _clipContents = artboard._clipContents;
    
        _color[0] = artboard._color[0];
        _color[1] = artboard._color[1];
        _color[2] = artboard._color[2];
        _color[3] = artboard._color[3];
    
        _actor = artboard._actor;
        _animations = artboard._animations;
        _drawableNodeCount = artboard._drawableNodeCount;
        _nodeCount = artboard._nodeCount;
    
        if (artboard.componentCount != 0) {
//            _components = Array<ActorComponent>(artboard.componentCount)
            _components = Array<ActorComponent?>()
        }
        if (_nodeCount != 0) // This will always be at least 1.
        {
//            _nodes = Array<ActorNode>(_nodeCount);
            _nodes = Array<ActorNode>()
        }
        if (_drawableNodeCount != 0) {
//            _drawableNodes = Array<ActorDrawable>(_drawableNodeCount);
            _drawableNodes = Array<ActorDrawable>()
        }
    
        if (artboard.componentCount != 0) {
            var idx = 0;
            var drwIdx = 0;
            var ndIdx = 0;
        
            for component in artboard.components! {
                if component == nil {
//                    _components[idx] = nil
                    _components!.insert(nil, at: idx)
                    idx += 1
                    continue
                }
                let instanceComponent = component!.makeInstance(self)
                _components!.insert(instanceComponent, at: idx)
                idx += 1

                if let instanceNode = instanceComponent as? ActorNode {
                    _nodes!.insert(instanceNode, at: ndIdx)
                    ndIdx += 1
                }
//                if (instanceComponent is ActorDrawable) {
//                    _drawableNodes[drwIdx] = instanceComponent as ActorDrawable
                if let instanceDrawable = instanceComponent as? ActorDrawable {
                    _drawableNodes.insert(instanceDrawable, at: drwIdx)
                    drwIdx += 1
                }
            }
        }
    
        _root = _components![0] as? ActorNode
    
        for component in _components! /*where (component != nil && component != _root)*/ {
            if (_root == component || component == nil) {
                continue;
            }
            component!.resolveComponentIndices(_components!);
        }
    
        for component in _components! /*where (component != nil && component != _root)*/ {
            if (_root == component || component == nil) {
                continue;
            }
            component!.completeResolve();
        }
    
        sortDependencies();

        _drawableNodes.sort{ $0.drawOrder > $1.drawOrder }
            for i in 0..<_drawableNodes.count {
                _drawableNodes[i].drawIndex = i
        }
        
//        if (_drawableNodes != null) {
//            _drawableNodes.sort((a, b) => a.drawOrder.compareTo(b.drawOrder));
//            for (int i = 0; i < _drawableNodes.length; i++) {
//                _drawableNodes[i].drawIndex = i;
//            }
//        }
    }
    
    public func advance(seconds: Double) {
        if (_flags & ActorFlags.IsDirty) != 0 {
            let MaxSteps = 100
            var step = 0
            let count = _dependencyOrder!.count
            while (_flags & ActorFlags.IsDirty) != 0 && step < MaxSteps {
                _flags &= ~ActorFlags.IsDirty;
                // Track dirt depth here so that if something else marks dirty, we restart.
//                for (int i = 0; i < count; i++) {
                for i in 0 ..< count {
                    let component = _dependencyOrder![i]
                    _dirtDepth = i
                    let d = component.dirtMask
                    if (d == 0) {
                        continue
                    }
                    component.dirtMask = 0
                    component.update(dirt: d)
                    if _dirtDepth < i {
                        break
                    }
                }
                step += 1
            }
        }
        
        if (_flags & ActorFlags.IsDrawOrderDirty) != 0 {
            _flags &= ~ActorFlags.IsDrawOrderDirty
            
        _drawableNodes.sort{ $0.drawOrder > $1.drawOrder }
        for i in 0..<_drawableNodes.count {
            _drawableNodes[i].drawIndex = i
        }
//            if (_drawableNodes != null) {
//                _drawableNodes.sort((a, b) => a.drawOrder.compareTo(b.drawOrder));
//                for (int i = 0; i < _drawableNodes.length; i++) {
//                    _drawableNodes[i].drawIndex = i;
//                }
//            }
        }
        if (_flags & ActorFlags.IsVertexDeformDirty) != 0 {
            _flags &= ~ActorFlags.IsVertexDeformDirty
//            for (int i = 0; i < _drawableNodeCount; i++) {
            for i in 0 ..< _drawableNodeCount {
                let drawable = _drawableNodes[i]
                
                if let image = drawable as? ActorImage {
                    if image.isVertexDeformDirty {
                        image.isVertexDeformDirty = false;
                    }
                    //updateVertexDeform(drawable);
                }
            }
        }
    }
    
    func read(_ reader: StreamReader) {
        _name = reader.readString(label: "name");
        reader.readFloat32Array(ar: &_translation.values, label: "translation");
        _width = Double(reader.readFloat32(label: "width"))
        _height = Double(reader.readFloat32(label: "height"))
        reader.readFloat32Array(ar: &_origin.values, label: "origin");
        _clipContents = reader.readBool(label: "clipContents");
        reader.readFloat32Array(ar: &_color, label: "color");
        
        while var block = reader.readNextBlock(blockTypes: BlockTypesMap) {
            switch (block.blockType) {
            case BlockTypes.Components:
                readComponentsBlock(block)
                break
            case BlockTypes.Animations:
                readAnimationsBlock(block)
                break
            default:
                print("ActorArtboard::read() - Unknown block type: \(block.blockType)")
                break
            }
        }
    }
    
    func readComponentsBlock(_ block: StreamReader) {
        let componentCount = Int(block.readUint16Length())
        _components = Array<ActorComponent>()
//        _components[0] = _root;
        _components?.insert(_root, at: 0)
        
        // Guaranteed from the exporter to be in index order.
        _nodeCount = 1;
//        for (int componentIndex = 1, end = componentCount + 1; componentIndex < end; componentIndex++) {
        let end = componentCount + 1
        for componentIndex in 1 ..< end {
            if let nodeBlock = block.readNextBlock(blockTypes: BlockTypesMap) {
                var component: ActorComponent?
                switch (nodeBlock.blockType) {
                case BlockTypes.ActorNode:
                    component = actor.makeNode()
                    (component as! ActorNode).readNode(self, nodeBlock)
                    break;
                    
                case BlockTypes.ActorBone:
//                    component = ActorBone.read(self, nodeBlock, nil);
                    break;
                    
                case BlockTypes.ActorRootBone:
//                    component = ActorRootBone.read(self, nodeBlock, nil);
                    break;
                    
                case BlockTypes.ActorImageSequence:
//                    component = ActorImage.readSequence(self, nodeBlock, actor.makeImageNode())
//                    let ai = component as ActorImage;
//                    actor.maxTextureIndex = ai.sequenceFrames.last.atlasIndex; // Last atlasIndex is the biggest
                    break;
                    
                case BlockTypes.ActorImage:
//                    component = ActorImage.read(self, nodeBlock, actor.makeImageNode());
//                    if ((component as ActorImage).textureIndex > actor.maxTextureIndex) {
//                        actor.maxTextureIndex = (component as ActorImage).textureIndex;
//                    }
                    break;
                    
                case BlockTypes.ActorIKTarget:
                    //component = ActorIKTarget.Read(self, nodeBlock);
                    break;
                    
                case BlockTypes.ActorEvent:
//                    component = ActorEvent.read(self, nodeBlock, actor.makeEvent())
                    component = actor.makeEvent()
                    (component as! ActorEvent).readEvent(self, nodeBlock)
                    break;
                    
                case BlockTypes.CustomIntProperty:
                    //component = CustomIntProperty.Read(self, nodeBlock);
                    break;
                    
                case BlockTypes.CustomFloatProperty:
                    //component = CustomFloatProperty.Read(self, nodeBlock);
                    break;
                    
                case BlockTypes.CustomStringProperty:
                    //component = CustomStringProperty.Read(self, nodeBlock);
                    break;
                    
                case BlockTypes.CustomBooleanProperty:
                    //component = CustomBooleanProperty.Read(self, nodeBlock);
                    break;
                    
                case BlockTypes.ActorColliderRectangle:
                    //component = ActorColliderRectangle.Read(self, nodeBlock);
                    break;
                    
                case BlockTypes.ActorColliderTriangle:
                    //component = ActorColliderTriangle.Read(self, nodeBlock);
                    break;
                    
                case BlockTypes.ActorColliderCircle:
                    //component = ActorColliderCircle.Read(self, nodeBlock);
                    break;
                    
                case BlockTypes.ActorColliderPolygon:
                    //component = ActorColliderPolygon.Read(self, nodeBlock);
                    break;
                    
                case BlockTypes.ActorColliderLine:
                    //component = ActorColliderLine.Read(self, nodeBlock);
                    break;
                    
                case BlockTypes.ActorNodeSolo:
//                    component = ActorNodeSolo.read(self, nodeBlock, nil);
                    break;
                    
                case BlockTypes.ActorJellyBone:
//                    component = ActorJellyBone.read(self, nodeBlock, nil);
                    break;
                    
                case BlockTypes.JellyComponent:
//                    component = JellyComponent.read(self, nodeBlock, nil);
                    break;
                    
                case BlockTypes.ActorIKConstraint:
//                    component = ActorIKConstraint.read(self, nodeBlock, nil);
                    break;
                    
                case BlockTypes.ActorDistanceConstraint:
//                    component = ActorDistanceConstraint.read(self, nodeBlock, nil);
                    break;
                    
                case BlockTypes.ActorTranslationConstraint:
//                    component = ActorTranslationConstraint.read(self, nodeBlock, nil);
                    break;
                    
                case BlockTypes.ActorScaleConstraint:
//                    component = ActorScaleConstraint.read(self, nodeBlock, nil);
                    break;
                    
                case BlockTypes.ActorRotationConstraint:
//                    component = ActorRotationConstraint.read(self, nodeBlock, nil);
                    break;
                    
                case BlockTypes.ActorTransformConstraint:
//                    component = ActorTransformConstraint.read(self, nodeBlock, nil);
                    break;
                    
                case BlockTypes.ActorShape:
//                    component = ActorShape.read(self, nodeBlock, actor.makeShapeNode());
                    component = actor.makeShapeNode()
                    (component as! ActorShape).readShape(self, nodeBlock)
                    break;
                    
                case BlockTypes.ActorPath:
//                    component = ActorPath.read(self, nodeBlock, actor.makePathNode());
                    component = actor.makePathNode()
                    (component as! ActorPath).readPath(self, nodeBlock)
                    break;
                    
                case BlockTypes.ColorFill:
//                    component = ColorFill.read(self, nodeBlock, actor.makeColorFill());
                    component = actor.makeColorFill()
                    (component as! ColorFill).readColorFill(self, nodeBlock)
                    break;
                    
                case BlockTypes.ColorStroke:
//                    component = ColorStroke.read(self, nodeBlock, actor.makeColorStroke());
                    component = actor.makeColorStroke()
                    (component as! ColorStroke).readColorStroke(self, nodeBlock)
                    break;
                    
                case BlockTypes.GradientFill:
//                    component = GradientFill.read(self, nodeBlock, actor.makeGradientFill());
                    component = actor.makeGradientFill()
                    (component as! GradientFill).readGradientFill(self, nodeBlock)
                    break;
                    
                case BlockTypes.GradientStroke:
//                    component = GradientStroke.read(self, nodeBlock, actor.makeGradientStroke());
                    component = actor.makeGradientStroke()
                    (component as! GradientStroke).readGradientStroke(self, nodeBlock)
                    break;
                    
                case BlockTypes.RadialGradientFill:
//                    component = RadialGradientFill.read(self, nodeBlock, actor.makeRadialFill());
                    component = actor.makeRadialFill()
                    (component as! RadialGradientFill).readRadialGradientFill(self, nodeBlock)
                    break;
                    
                case BlockTypes.RadialGradientStroke:
//                    component = RadialGradientStroke.read(self, nodeBlock, actor.makeRadialStroke());
                    component = actor.makeRadialStroke()
                    (component as! RadialGradientStroke).readRadialGradientStroke(self, nodeBlock)
                    break;
                    
                case BlockTypes.ActorEllipse:
//                    component = ActorEllipse.read(self, nodeBlock, actor.makeEllipse());
                    component = actor.makeEllipse()
                    (component as! ActorEllipse).readEllipse(self, nodeBlock)
                    break;
                    
                case BlockTypes.ActorRectangle:
//                    component = ActorRectangle.read(self, nodeBlock, actor.makeRectangle());
                    component = actor.makeRectangle()
                    (component as! ActorRectangle).readRectangle(self, nodeBlock)
                    break;
                    
                case BlockTypes.ActorTriangle:
//                    component = ActorTriangle.read(self, nodeBlock, actor.makeTriangle());
                    component = actor.makeTriangle()
                    (component as! ActorTriangle).readTriangle(self, nodeBlock)
                    break;
                    
                case BlockTypes.ActorStar:
//                    component = ActorStar.read(self, nodeBlock, actor.makeStar());
                    component = actor.makeStar()
                    (component as! ActorStar).readStar(self, nodeBlock)
                    break;
                    
                case BlockTypes.ActorPolygon:
//                    component = ActorPolygon.read(self, nodeBlock, actor.makePolygon());
                    component = actor.makePolygon()
                    (component as! ActorPolygon).readPolygon(self, nodeBlock)
                    break;
                case BlockTypes.ActorSkin:
//                    component = ActorComponent.read(self, nodeBlock, ActorSkin());
                    component = ActorSkin()
                    component!.readComponent(self, nodeBlock)
                    break;
                default:
                    break
                }
                if (component is ActorDrawable) {
                    _drawableNodeCount += 1
                }
                
                if (component is ActorNode) {
                    _nodeCount += 1
                }
//                _components![componentIndex] = component
                _components!.insert(component, at: componentIndex)
                if component != nil {
                    component!.idx = componentIndex;
                }
            }
        }
        
//        _drawableNodes = List<ActorDrawable>(_drawableNodeCount);
        _drawableNodes = [ActorDrawable]()
//        _nodes = List<ActorNode>(_nodeCount);
        _nodes = [ActorNode]()
//        _nodes[0] = _root;
        _nodes!.insert(_root, at: 0)
        
        // Resolve nodes.
        var drwIdx = 0;
        var anIdx = 0;
        
//        for (int i = 1; i <= componentCount; i++) {
        for i in 1 ... componentCount {
            // Nodes can be nil if we read from a file version that contained nodes that we don't interpret in this runtime.
            if let c = _components![i] {
                c.resolveComponentIndices(_components!);
                
                if c is ActorDrawable {
//                    _drawableNodes[drwIdx] = c as! ActorDrawable
                    _drawableNodes.insert(c as! ActorDrawable, at: drwIdx)
                    drwIdx += 1
                }
                
                if let an = c as? ActorNode {
//                    _nodes[anIdx] = an
                    _nodes!.insert(an, at: anIdx)
                    anIdx += 1
                }
            }
            
        }
        
//        for (int i = 1; i <= componentCount; i++) {
        for i in 1 ... componentCount {
            if let c = components![i] {
                c.completeResolve();
            }
        }
        
        sortDependencies();
    }
    
    func readAnimationsBlock(_ block: StreamReader) {
        // Read animations.
        _ = block.readUint16Length() // Needed to preserve alignment
        _animations = Array<ActorAnimation>()
        var animationIndex = 0
        
        while let animationBlock = block.readNextBlock(blockTypes: BlockTypesMap) {
            switch (animationBlock.blockType) {
            case BlockTypes.Animation:
                let anim = ActorAnimation.read(reader: animationBlock, components: &_components!)
                _animations?.insert(anim, at: animationIndex)
                animationIndex += 1
//                _animations[animationIndex++] = anim
                break
            default:
                print("READING ANIMATIONS BLOCK? \(animationBlock.blockType)")
                break
            }
        }
    }
    
    public func initializeGraphics() {
        for drawable in _drawableNodes {
            drawable.initializeGraphics()
        }
    }
    
    public func artboardAABB() -> AABB {
        let fw = Float32(_width)
        let fh = Float32(_height)
        let minX = -_origin[0] * fw
        let minY = -_origin[1] * fh
        return AABB.init(fromValues: minX, minY, minX + fw, minY + fh)
    }
    
    func computeAABB() -> AABB? {
        var aabb: AABB? = nil
        for drawable in _drawableNodes {
            let pathAABB = drawable.computeAABB()
            if let bb = aabb {
                // Already defined: combine.
                bb[0] = min(bb[0], pathAABB[0])
                bb[1] = min(bb[1], pathAABB[1])
                
                bb[2] = max(bb[2], pathAABB[2])
                bb[3] = max(bb[3], pathAABB[3])
            } else {
                aabb = pathAABB
            }
        }
        return aabb
    }
    
    public func draw(context: CGContext) {}
}
