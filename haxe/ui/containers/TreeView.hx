package haxe.ui.containers;

/***************************************************************************************************
 * Note, this treeview is experimental and the API is likely to change without notice.
 * Currently you can ONLY populate it via code, it WILL NOT work with <data> from xml, or a
 * .dataSource in general - this is something that WILL BE fixed for an official release
 * 
 * There is also NO native (wx) counterpart for this yet. Use at your own risk! For general use
 * its probably fine, however its not considered a FULL HAXEUI component yet!
 * 
 * Examples of usage can be found at the end of this file
 ***************************************************************************************************/

import haxe.ui.containers.ScrollView;
import haxe.ui.core.BasicItemRenderer;
import haxe.ui.core.Component;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.data.DataSource;
import haxe.ui.events.UIEvent;

@:access(haxe.ui.containers.TreeViewNode)
@:composite(TreeViewEvents, TreeViewBuilder)
class TreeView extends ScrollView implements IDataComponent {
    public function new() {
        super();
    }
    
    private var _dataSource:DataSource<Dynamic> = null;
    public var dataSource(get, set):DataSource<Dynamic>;
    private function get_dataSource():DataSource<Dynamic> {
        if (_dataSource == null) {
            _dataSource = new ArrayDataSource<Dynamic>();
            _dataSource.onChange = onDataChanged;
        }
        return _dataSource;
    }
    private function set_dataSource(value:DataSource<Dynamic>):DataSource<Dynamic> {
        var dataSource:DataSource<Dynamic> = value;
        if (dataSource != null) {
            _dataSource = dataSource;
            _dataSource.onChange = onDataChanged;
        }
        syncNodes();
        return value;
    }
    
    private var _selectedNode:TreeViewNode = null;
    public var selectedNode(get, set):TreeViewNode;
    private function get_selectedNode():TreeViewNode {
        return _selectedNode;
    }
    private function set_selectedNode(value:TreeViewNode):TreeViewNode {
        if (value == _selectedNode) {
            return value;
        }

        clearSelection();
        
        _selectedNode = value;
        if (_selectedNode != null) {
            var p = _selectedNode.parentNode;
            while (p != null) {
                p.expanded = true;
                p = p.parentNode;
            }
            var renderer = _selectedNode.findComponent(ItemRenderer, true);
            if (renderer != null) {
                renderer.addClass(":node-selected", true, true);
            }
        }
        
        var event:UIEvent = new UIEvent(UIEvent.CHANGE);
        this.dispatch(event);
        
        return value;
    }
    
    public function clearSelection() {
        if (_selectedNode != null) {
            var renderer = _selectedNode.findComponent(ItemRenderer, true);
            if (renderer != null) {
                renderer.removeClass(":node-selected", true, true);
            }
            _selectedNode = null;
        }
    }
    
    private function onDataChanged() {
    }
    
    private function syncNodes() {
        for (i in 0..._dataSource.size) {
            var item = _dataSource.get(i);
            syncNode(i, item);
        }
    }
    
    private function syncNode(index:Int, nodeData:Dynamic) {
        var node:TreeViewNode = getNodes()[index];
        if (node == null) {
            node = new TreeViewNode();
            addComponent(node);
        }
        node.data = nodeData;
    }
    
    public function getNodes():Array<TreeViewNode> {
        return findComponents(TreeViewNode, 3); // TODO: is this brittle? Will it always be 3?
    }
    
    private var _itemRenderer:ItemRenderer = new BasicItemRenderer();
    public var itemRenderer(get, set):ItemRenderer;
    private function get_itemRenderer():ItemRenderer {
        return _itemRenderer;
    }
    private function set_itemRenderer(value:ItemRenderer):ItemRenderer {
        if (_itemRenderer != value) {
            _itemRenderer = value;
            //invalidateComponentLayout();
        }

        return value;
    }
    
    private var _expandableItemRenderer:ItemRenderer = null;
    public var expandableItemRenderer(get, set):ItemRenderer;
    private function get_expandableItemRenderer():ItemRenderer {
        if (_expandableItemRenderer == null) {
            return _itemRenderer;
        }
        return _expandableItemRenderer;
    }
    private function set_expandableItemRenderer(value:ItemRenderer):ItemRenderer {
        if (_expandableItemRenderer != value) {
            _expandableItemRenderer = value;
            //invalidateComponentLayout();
        }

        return value;
    }
    
    public function addNode(data:Dynamic):TreeViewNode {
        var node = new TreeViewNode();
        node.data = data;
        addComponent(node);
        return node;
    }

    public function removeNode(node:TreeViewNode):TreeViewNode {
        removeComponent(node);
        return node;
    }
    
    public function clearNodes() {
        selectedNode = null;
        var nodes = findComponents(TreeViewNode, 3);
        for (n in nodes) {
            removeComponent(n);
        }
    }
    
    private override function onReady() {
        super.onReady();
        if (_selectedNode != null) {
            var node = _selectedNode;
            _selectedNode = null;
            selectedNode = node;
        }
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
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class TreeViewEvents extends ScrollViewEvents {
    @:keep private var _treeview:TreeView;
    
    public function new(treeview:TreeView) {
        super(treeview);
        _treeview = treeview;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.containers.TreeView)
private class TreeViewBuilder extends ScrollViewBuilder {
    private var _treeview:TreeView;
    
    public function new(treeview:TreeView) {
        super(treeview);
        _treeview = treeview;
    }
    
    public override function addComponent(child:Component) {
        if ((child is ItemRenderer)) {
            if (child.id == null) {
                _treeview._itemRenderer = cast child;
            } else if (child.id == "expandable") {
                _treeview._expandableItemRenderer = cast child;
            }
            return child;
        }
        return super.addComponent(child);
    }
}




/***************************************************************************************************
 * XML Examples:
 * -------------------------------------------------------------------------------------------------
 * 
 * <!-- DEFAULT TREEVIEW -->
 * <tree-view id="tv0" width="200" height="300" />
 * 
 * 
 * 
 * <!-- CUSTOM TREEVIEW -->
 * <tree-view id="tv1" width="500" height="300" styleName="full-width">
 *     <item-renderer layoutName="horizontal" width="100%">
 *         <checkbox id="checked" verticalAlign="center" />
 *         <image id="icon" verticalAlign="center" />
 *         <label id="text" verticalAlign="center" width="100%" />
 *         <progress id="progress" verticalAlign="center" />
 *         <image resource="haxeui-core/styles/default/tiny-close-button.png" verticalAlign="center" />
 *     </item-renderer>
 *     <item-renderer id="expandable" layoutName="horizontal" width="100%">
 *         <image resource="haxeui-core/styles/default/folder.png" verticalAlign="center" />
 *         <label id="text" width="100%" verticalAlign="center" />
 *         <hbox style="background-color: #eeeeee;border-radius:3px;padding: 1px 3px;spacing:0;" verticalAlign="center">
 *             <label id="count" style="color:#888888;font-size: 11px;" />
 *             <label text=" children" style="color:#888888;font-size: 11px;" />
 *         </hbox>
 *         <switch verticalAlign="center" />
 *     </item-renderer>
 * </tree-view>    
 * 
 * 
 * 
 * Population Examples (via code only for now):
 * -------------------------------------------------------------------------------------------------
 * 
 * var root1 = tv0.addNode({ text: "root A", icon: "haxeui-core/styles/default/haxeui_tiny.png" });
 *     var child = root1.addNode({ text: "child A-1", icon: "haxeui-core/styles/default/haxeui_tiny.png" });
 *         var node = child.addNode({ text: "child A-1-1", icon: "haxeui-core/styles/default/haxeui_tiny.png" });
 *         var node = child.addNode({ text: "child A-1-2", icon: "haxeui-core/styles/default/haxeui_tiny.png" });
 *         var node = child.addNode({ text: "child A-1-3", icon: "haxeui-core/styles/default/haxeui_tiny.png" });
 *     var child = root1.addNode({ text: "child A-2", icon: "haxeui-core/styles/default/haxeui_tiny.png" });
 *         var node = child.addNode({ text: "child A-2-1", icon: "haxeui-core/styles/default/haxeui_tiny.png" });
 *         var node = child.addNode({ text: "child A-2-2", icon: "haxeui-core/styles/default/haxeui_tiny.png" });
 *     var child = root1.addNode({ text: "child A-3", icon: "haxeui-core/styles/default/haxeui_tiny.png" });
 *         var node = child.addNode({ text: "child A-3-1", icon: "haxeui-core/styles/default/haxeui_tiny.png" });
 *         var node = child.addNode({ text: "child A-3-2", icon: "haxeui-core/styles/default/haxeui_tiny.png" });
 *         var node = child.addNode({ text: "child A-3-3", icon: "haxeui-core/styles/default/haxeui_tiny.png" });
 *         var node = child.addNode({ text: "child A-3-4", icon: "haxeui-core/styles/default/haxeui_tiny.png" });
 *     var child = root1.addNode({ text: "child A-4", icon: "haxeui-core/styles/default/haxeui_tiny.png" });
 *     var child = root1.addNode({ text: "child A-5", icon: "haxeui-core/styles/default/haxeui_tiny.png" });
 * 
 * 
 * 
 * var root1 = tv1.addNode({ text: "root A", icon: "haxeui-core/styles/default/haxeui_tiny.png", count: 5 });
 *     var child = root1.addNode({ text: "child A-1", icon: "haxeui-core/styles/default/haxeui_tiny.png", progress: Std.random(100), count: 3, checked: Std.random(2) == 0 });
 *         var node = child.addNode({ text: "child A-1-1", icon: "haxeui-core/styles/default/haxeui_tiny.png", progress: Std.random(100), checked: Std.random(2) == 0 });
 *         var node = child.addNode({ text: "child A-1-2", icon: "haxeui-core/styles/default/haxeui_tiny.png", progress: Std.random(100), checked: Std.random(2) == 0 });
 *         var node = child.addNode({ text: "child A-1-3", icon: "haxeui-core/styles/default/haxeui_tiny.png", progress: Std.random(100), checked: Std.random(2) == 0 });
 *     var child = root1.addNode({ text: "child A-2", icon: "haxeui-core/styles/default/haxeui_tiny.png", progress: Std.random(100), count: 2, checked: Std.random(2) == 0 });
 *         var node = child.addNode({ text: "child A-2-1", icon: "haxeui-core/styles/default/haxeui_tiny.png", progress: Std.random(100), checked: Std.random(2) == 0 });
 *         var node = child.addNode({ text: "child A-2-2", icon: "haxeui-core/styles/default/haxeui_tiny.png", progress: Std.random(100), checked: Std.random(2) == 0 });
 *     var child = root1.addNode({ text: "child A-3", icon: "haxeui-core/styles/default/haxeui_tiny.png", progress: Std.random(100), count: 4, checked: Std.random(2) == 0 });
 *         var node = child.addNode({ text: "child A-3-1", icon: "haxeui-core/styles/default/haxeui_tiny.png", progress: Std.random(100), checked: Std.random(2) == 0 });
 *         var node = child.addNode({ text: "child A-3-2", icon: "haxeui-core/styles/default/haxeui_tiny.png", progress: Std.random(100), checked: Std.random(2) == 0 });
 *         var node = child.addNode({ text: "child A-3-3", icon: "haxeui-core/styles/default/haxeui_tiny.png", progress: Std.random(100), checked: Std.random(2) == 0 });
 *         var node = child.addNode({ text: "child A-3-4", icon: "haxeui-core/styles/default/haxeui_tiny.png", progress: Std.random(100), checked: Std.random(2) == 0 });
 *     var child = root1.addNode({ text: "child A-4", icon: "haxeui-core/styles/default/haxeui_tiny.png", progress: Std.random(100), count: 3, checked: Std.random(2) == 0 });
 *     var child = root1.addNode({ text: "child A-5", icon: "haxeui-core/styles/default/haxeui_tiny.png", progress: Std.random(100), count: 3, checked: Std.random(2) == 0 });
 ***************************************************************************************************/

 
