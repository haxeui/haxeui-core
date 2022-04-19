package haxe.ui.containers;

import haxe.ui.components.Image;
import haxe.ui.containers.Box;
import haxe.ui.containers.HBox;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.ItemRenderer;
import haxe.ui.events.MouseEvent;

#if (haxe_ver >= 4.2)
import Std.isOfType;
#else
import Std.is as isOfType;
#end

@:composite(TreeViewNodeEvents, TreeViewNodeBuilder)
class TreeViewNode extends VBox {
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
    
    public function matchesPathPart(part:String, field:String = null):Bool {
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
    
    public function addNode(data:Dynamic):TreeViewNode {
        var node = new TreeViewNode();
        node.parentNode = this;
        node.data = data;
        addComponent(node);
        return node;
    }
    
    public function removeNode(node:TreeViewNode):TreeViewNode {
        removeComponent(node);
        return node;
    }
    
    private function getNodes():Array<TreeViewNode> {
        return findComponents(TreeViewNode, 3); // TODO: is this brittle? Will it always be 3?
    }
    
    public var expandable(get, null):Bool;
    private function get_expandable():Bool {
        var childContainer = findComponent("treenode-child-container", Box);
        return (childContainer != null && childContainer.numComponents > 0);
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
    
    private var _expanded:Bool = false;
    public var expanded(get, set):Bool;
    private function get_expanded():Bool {
        var childContainer = findComponent("treenode-child-container", Box);
        if (childContainer == null) {
            return _expanded;
        }
        return !childContainer.hidden;
    }
    private function set_expanded(value:Bool):Bool {
        _expanded = value;
        var childContainer = findComponent("treenode-child-container", Box);
        if (childContainer == null) {
            return value;
        }
        
        if (value == true) {
            childContainer.show();
        } else {
            childContainer.hide();
        }
        
        return value;
    }
    
    private var _data:Dynamic;
    public var data(get, set):Dynamic;
    private function get_data():Dynamic {
        return _data;
    }
    private function set_data(value:Dynamic):Dynamic {
        if (value == _data) {
            return value;
        }

        _data = value;
        syncChildNodes();
        invalidateComponentData();
        return value;
    }
    
    private function syncChildNodes() {
        var childDataArray:Array<Dynamic> = null;
        for (f in Reflect.fields(_data)) { // TODO: ill concieved?
            switch (Type.typeof(Reflect.field(_data, f))) {
                case TClass(Array):
                    childDataArray = Reflect.field(_data, f);
                    break;
                case _:
            }
        }
        
        if (childDataArray != null) {
            var i = 0;
            for (childData in childDataArray) {
                var childNode:TreeViewNode = getChildNodes()[i];
                if (childNode == null) {
                    childNode = new TreeViewNode();
                    addComponent(childNode);
                }
                childNode.data = childData;
                i++;
            }
        }
    }
    
    private function getChildNodes():Array<TreeViewNode> {
        return findComponents(TreeViewNode, 3); // TODO: is this brittle? Will it always be 3?
    }
    
    public function clearNodes() {
        var nodes = findComponents(TreeViewNode, 3);
        for (n in nodes) {
            removeComponent(n);
        }
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************

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
        _expandCollapseIcon.scriptAccess = false;
        _expandCollapseIcon.addClass("treenode-expand-collapse-icon");
        _expandCollapseIcon.id = "treenode-expand-collapse-icon";
        _expandCollapseIcon.registerEvent(MouseEvent.CLICK, onExpandCollapseClicked);
        _nodeContainer.registerEvent(MouseEvent.CLICK, onContainerClick);
        _nodeContainer.registerEvent(MouseEvent.DBL_CLICK, onContainerDblClick);
        _nodeContainer.addComponent(_expandCollapseIcon);

        _renderer = treeview.itemRenderer.cloneComponent();
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
        var treeview = _node.findAncestor(TreeView);
        treeview.selectedNode = _node;
    }
    
    private function onContainerDblClick(_) {
        onExpandCollapseClicked(null);
    }
    
    private function onExpandCollapseClicked(_) {
        _node.expanded = !_node.expanded;
        if (_expandCollapseIcon != null) {
            if (_childContainer != null) {
                if (_childContainer.hidden == true) {
                    _expandCollapseIcon.swapClass("node-collapsed", "node-expanded");
                } else {
                    _expandCollapseIcon.swapClass("node-expanded", "node-collapsed");
                }
            }
        }
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
                treeview.clearSelection();
                treeview.selectedNode = _node;
            }
        }
    }
    
    private function makeExpandableRendererChanges() {
        var treeview = _node.findAncestor(TreeView);
        
        if (_expandCollapseIcon != null) {
            if (_childContainer != null) {
                if (_childContainer.hidden == true) {
                    _expandCollapseIcon.swapClass("node-collapsed", "node-expanded");
                } else {
                    _expandCollapseIcon.swapClass("node-expanded", "node-collapsed");
                }
            }
        }
        
        if (_renderer != null) {
            var wasSelected = (treeview.selectedNode == _node);
            var data = _renderer.data;
            var newRenderer = treeview.expandableItemRenderer.cloneComponent();
            newRenderer.data = data;
            _nodeContainer.removeComponent(_renderer);
            _renderer = newRenderer;
            _nodeContainer.addComponent(newRenderer);
            if (wasSelected == true) {
                treeview.clearSelection();
                treeview.selectedNode = _node;
            }
        }
    }
    
    public override function addComponent(child:Component) {
        if (child == _renderer || child == _childContainer) {
            return null;
        }
        
        if ((child is TreeViewNode)) {
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
    
    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true) {
        if ((child is TreeViewNode)) {
            cast(child, TreeViewNode).parentNode = null;
            var c = _childContainer.removeComponent(child, dispose, invalidate);
            if (_childContainer.numComponents == 0) {
                changeToNonExpandableRenderer();
            }
            return c;
        }
        return null;
    }
}
