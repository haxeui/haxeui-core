package haxe.ui.containers;

import haxe.ui.behaviours.Behaviour;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.components.Image;
import haxe.ui.containers.Box;
import haxe.ui.containers.HBox;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.TreeViewEvent;
import haxe.ui.util.Variant;
import haxe.ui.containers.TreeView.TreeViewEvent;

#if (haxe_ver >= 4.2)
import Std.isOfType;
#else
import Std.is as isOfType;
#end

@:composite(TreeViewNodeEvents, TreeViewNodeBuilder)
class TreeViewNode extends VBox {
    @:behaviour(Expanded, false)        public var expanded:Bool;
    @:behaviour(Expandable)             public var expandable:Null<Bool>;
    
    @:call(AddNode)                     public function addNode(data:Dynamic):TreeViewNode;
    @:call(RemoveNode)                  public function removeNode(node:TreeViewNode):TreeViewNode;
    @:call(ClearNodes)                  public function clearNodes():Void;
    @:call(GetNodesInternal)            private function getNodesInternal():Array<Component>;
    
    public var parentNode:TreeViewNode = null;
    
    public function nodePath(field:String = null):String {
        if (field == null) { // lets try to guess a field to use in the path
            if (Reflect.hasField(this.data, "id")) {
                field = "id";
            } else if (Reflect.hasField(this.data, "nodeId")) {
                field = "nodeId";
            } else {
                field = "text";
            }
        }
        var parts = [];
        var p = this;
        while (p != null) {
            parts.push(Reflect.field(p.data, field));
            p = p.parentNode;
        }
        parts.reverse();
        return parts.join("/");
    }
    
    public function findNodes(fieldValue:Any, fieldName:String = null):Array<TreeViewNode> {
        if (fieldName == null) { // lets try to guess a field to use
            fieldName = "text";
        }

        var foundNodes = [];
        if (Reflect.hasField(this.data, fieldName)) {
            var nodeFieldValue = Reflect.field(this.data, fieldName);
            if (nodeFieldValue == fieldValue) {
                foundNodes.push(this);
            }
        }

        for (child in getNodes()) {
            var childNodesFound = child.findNodes(fieldValue, fieldName);
            if (childNodesFound != null && childNodesFound.length > 0) {
                foundNodes = foundNodes.concat(childNodesFound);
            }
        }

        return foundNodes;
    }

    public function findNode(fieldValue:Any, fieldName:String = null):TreeViewNode {
        if (fieldName == null) { // lets try to guess a field to use
            fieldName = "text";
        }

        if (Reflect.hasField(this.data, fieldName)) {
            var nodeFieldValue = Reflect.field(this.data, fieldName);
            if (nodeFieldValue == fieldValue) {
                return this;
            }
        }

        var foundNode = null;
        for (child in getNodes()) {
            foundNode = child.findNode(fieldValue, fieldName);
            if (foundNode != null) {
                break;
            }
        }

        return foundNode;
    }

    public function findNodeByPath(path:String, field:String = null):TreeViewNode {
        var foundNode = null;
        
        var parts = path.split("/");
        var part = parts.shift();
        
        var nodes = getNodes();
        for (node in nodes) {
            if (node.matchesPathPart(part, field)) {
                if (parts.length == 0) {
                    foundNode = node;
                } else {
                    foundNode = node.findNodeByPath(parts.join("/"), field);
                }
                break;
            }
        }
        
        return foundNode;
    }
    
    private function matchesPathPart(part:String, field:String = null):Bool {
        if (field == null) { // lets try to guess a field to use in the path
            if (Reflect.hasField(this.data, "id")) {
                field = "id";
            } else if (Reflect.hasField(this.data, "nodeId")) {
                field = "nodeId";
            } else {
                field = "text";
            }
        }
        
        if (Reflect.hasField(this.data, field) == false) {
            return false;
        }
        
        return Std.string(Reflect.field(this.data, field)) == part;
    }
    
    public function getNodes():Array<TreeViewNode> {
        var nodes:Array<TreeViewNode> = [];
        var internalNodes = getNodesInternal();
        for (node in internalNodes) {
            nodes.push(cast node);
        }
        return nodes;
    }
    
    public var selected(get, set):Bool;
    private function get_selected():Bool {
        var treeview = findAncestor(TreeView);
        return treeview.selectedNode == this;
    }
    private function set_selected(value:Bool):Bool {
        var treeview = findAncestor(TreeView);
        treeview.selectedNode = this;
        return value;
    }
    
    private var _data:Dynamic = null;
    public var data(get, set):Dynamic;
    private function get_data():Dynamic {
        return _data;
    }
    private function set_data(value:Dynamic):Dynamic {
        if (value == _data) {
            return value;
        }

        _data = value;
        invalidateComponentData();
        return value;
    }
    
    private override function get_text():String {
        return _data.text;
    }
    private override function set_text(value:String):String {
        if (_data == null) {
            _data = {};
        }
        _data.text = value;
        this.data = Reflect.copy(_data); // TEMP
        return value;
    }
    
    private override function get_icon():Variant {
        return Variant.fromDynamic(_data.icon);
    }
    private override function set_icon(value:Variant):Variant {
        if (_data == null) {
            _data = {};
        }
        _data.icon = value;
        this.data = Reflect.copy(_data); // TEMP
        return value;
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class AddNode extends Behaviour {
    public override function call(param:Any = null):Variant {
        var node = new TreeViewNode();
        node.data = param;
        _component.addComponent(node);
        return node;
    }
}

@:dox(hide) @:noCompletion
private class RemoveNode extends Behaviour {
    public override function call(param:Any = null):Variant {
        var node:TreeViewNode = param;
        _component.removeComponent(node);
        return node;
    }
}

@:dox(hide) @:noCompletion
private class ClearNodes extends Behaviour {
    public override function call(param:Any = null):Variant {
        var node:TreeViewNode = cast(_component, TreeViewNode);
        var nodes = node.findComponents(TreeViewNode, 3);
        for (n in nodes) {
            node.removeComponent(n);
        }
        return null;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Expanded extends DataBehaviour {
    private override function validateData() {
        var childContainer = _component.findComponent("treenode-child-container", Box);
        if (childContainer != null) {
            if (_value == true) {
                childContainer.show();
            } else {
                childContainer.hide();
            }

            var builder:TreeViewNodeBuilder = cast(_component._compositeBuilder, TreeViewNodeBuilder);
            builder.updateIconClass();
        }
        
        var eventType = TreeViewEvent.NODE_EXPANDED;
        if (_value == false) {
            eventType = TreeViewEvent.NODE_COLLAPSED;
        }
        var event = new TreeViewEvent(eventType);
        event.node = cast(_component, TreeViewNode);
        var treeview = _component.findAncestor(TreeView);
        treeview.dispatch(event);

        
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Expandable extends DataBehaviour {
    private override function validateData() {
        var builder:TreeViewNodeBuilder = cast(_component._compositeBuilder, TreeViewNodeBuilder);
        if (_value == true) {
            @:privateAccess builder.changeToExpandableRenderer();
        } else {
            @:privateAccess builder.changeToNonExpandableRenderer();
        }
    }
}

@:dox(hide) @:noCompletion
private class GetNodesInternal extends Behaviour {
    public override function call(param:Any = null):Variant {
        var nodes = _component.findComponents(TreeViewNode, 3); // TODO: is this brittle? Will it always be 3?
        return nodes;
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class TreeViewNodeEvents extends haxe.ui.events.Events {
    @:keep private var _node:TreeViewNode;
    
    public function new(node:TreeViewNode) {
        super(node);
        _node = node;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class TreeViewNodeBuilder extends CompositeBuilder {
    private var _node:TreeViewNode;
    private var _nodeContainer:HBox = null;
    private var _expandCollapseIcon:Image = null;
    private var _renderer:ItemRenderer = null;
    private var _childContainer:VBox = null;
    
    private var _isExpandable:Bool = false;
    
    public function new(node:TreeViewNode) {
        super(node);
        _node = node;
    }
    
    public override function onInitialize() {
        var treeview = _node.findAncestor(TreeView);
        
        _nodeContainer = new HBox();
        _nodeContainer.addClass("treenode-container");
        _expandCollapseIcon = new Image();
        _expandCollapseIcon.addClass("treenode-expand-collapse-icon");
        _expandCollapseIcon.id = "treenode-expand-collapse-icon";
        _expandCollapseIcon.registerEvent(MouseEvent.CLICK, onExpandCollapseClicked);
        _nodeContainer.registerEvent(MouseEvent.CLICK, onContainerClick);
        _nodeContainer.registerEvent(MouseEvent.RIGHT_CLICK, onContainerClick);
        _nodeContainer.registerEvent(MouseEvent.DBL_CLICK, onContainerDblClick);
        _nodeContainer.addComponent(_expandCollapseIcon);

        _renderer = treeview.itemRenderer.cloneComponent();
        _renderer.itemIndex = _node.parentComponent.getComponentIndex(_node);
        _renderer.data = _node.data;
        _nodeContainer.addComponent(_renderer);
        
        
        if (_isExpandable == true) {
            makeExpandableRendererChanges();
        }
        _node.addComponentAt(_nodeContainer, 0);
    }

    private function onContainerClick(event:MouseEvent) {
        if (_expandCollapseIcon.hitTest(event.screenX, event.screenY)) {
            return;
        }

        var interactives = _node.findComponentsUnderPoint(event.screenX, event.screenY, InteractiveComponent);
        if (interactives.length > 0) {
            return;
        }
        
        var treeview = _node.findAncestor(TreeView);
        treeview.selectedNode = _node;
    }
    
    private function onContainerDblClick(event:MouseEvent) {
        var interactives = _node.findComponentsUnderPoint(event.screenX, event.screenY, InteractiveComponent);
        if (interactives.length > 0) {
            return;
        }
        
        onExpandCollapseClicked(event);
    }
    
    private function onExpandCollapseClicked(event:MouseEvent) {
        if (!_isExpandable) {
            return;
        }
        event.cancel();
        var treeview = _node.findAncestor(TreeView);
        _node.expanded = !_node.expanded;
        updateIconClass();
        var event = new TreeViewEvent(TreeViewEvent.NODE_COLLAPSE_EXPAND);
        event.expand = _node.expanded;
        event.affected_node = _node;
        treeview.dispatch(event);
    }
    
    public function updateIconClass() {
        if (_expandCollapseIcon != null) {
            if (_node.expanded == true) {
                _expandCollapseIcon.swapClass("node-expanded", "node-collapsed");
            } else {
                _expandCollapseIcon.swapClass("node-collapsed", "node-expanded");
            }
        }
    }
    
    public override function validateComponentData() {
        _renderer.data = _node.data;
    }
    
    private function changeToExpandableRenderer() {
        if (_isExpandable == true) {
            return;
        }
        
        _isExpandable = true;
        makeExpandableRendererChanges();
    }
    
    private function changeToNonExpandableRenderer() {
        if (_isExpandable == false) {
            return;
        }
        
        _isExpandable = false;
        makeNonExpandableRendererChanges();
    }
    
    private function makeNonExpandableRendererChanges() {
        var treeview = _node.findAncestor(TreeView);
        
        if (_expandCollapseIcon != null) {
            _expandCollapseIcon.removeClasses(["node-collapsed", "node-expanded"]);
        }
        
        if (_renderer != null) {
            var wasSelected = (treeview.selectedNode == _node);
            var data = _renderer.data;
            var newRenderer = treeview.itemRenderer.cloneComponent();
            newRenderer.data = data;
            _nodeContainer.removeComponent(_renderer);
            _renderer = newRenderer;
            _nodeContainer.addComponent(newRenderer);
            if (wasSelected == true) {
                //treeview.clearSelection();
                treeview.selectedNode = _node;
            }
        }
    }
    
    private function makeExpandableRendererChanges() {
        var treeview = _node.findAncestor(TreeView);
        
        updateIconClass();
        if (_renderer != null) {
            var wasSelected = (treeview.selectedNode == _node);
            var itemIndex = _renderer.itemIndex;
            var data = _renderer.data;
            var newRenderer = treeview.expandableItemRenderer.cloneComponent();
            newRenderer.data = data;
            newRenderer.itemIndex = itemIndex;
            _nodeContainer.removeComponent(_renderer);
            _renderer = newRenderer;
            _nodeContainer.addComponent(newRenderer);
            if (wasSelected == true) {
                //treeview.clearSelection();
                treeview.selectedNode = _node;
            }
        }
    }
    
    public override function addComponent(child:Component) {
        if (child == _renderer || child == _childContainer) {
            return null;
        }
        
        if ((child is TreeViewNode)) {
            cast(child, TreeViewNode).parentNode = _node;
            if (_childContainer == null) {
                _childContainer = new VBox();
                if (_node.expanded == true) {
                    _childContainer.show();
                } else {
                    _childContainer.hide();
                }
                _childContainer.addClass("treenode-child-container");
                _childContainer.id = "treenode-child-container";
                _node.addComponent(_childContainer);
            }
            changeToExpandableRenderer();
            return _childContainer.addComponent(child);
        }
        
        return null;
    }
	
	public override function addComponentAt(child:Component, index:Int) {
        if (child == _renderer || child == _childContainer) {
            return null;
        }
        
        if ((child is TreeViewNode)) {
            cast(child, TreeViewNode).parentNode = _node;
            if (_childContainer == null) {
                _childContainer = new VBox();
                if (_node.expanded == true) {
                    _childContainer.show();
                } else {
                    _childContainer.hide();
                }
                _childContainer.addClass("treenode-child-container");
                _childContainer.id = "treenode-child-container";
                _node.addComponent(_childContainer);
            }
            changeToExpandableRenderer();
            return _childContainer.addComponentAt(child,index);
        }
        
        return null;
    }
    
    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true) {
        if ((child is TreeViewNode)) {
            cast(child, TreeViewNode).parentNode = null;
            var c = _childContainer.removeComponent(child, dispose, invalidate);
            if (_childContainer.numComponents == 0 && _node.expandable != true) {
                changeToNonExpandableRenderer();
            }
            return c;
        }
        return null;
    }
}
