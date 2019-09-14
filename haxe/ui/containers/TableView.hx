package haxe.ui.containers;

import haxe.ui.behaviours.Behaviour;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.behaviours.LayoutBehaviour;
import haxe.ui.binding.BindingManager;
import haxe.ui.components.Label;
import haxe.ui.components.VerticalScroll;
import haxe.ui.constants.SelectionMode;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.ScrollView.ScrollViewBuilder;
import haxe.ui.core.Component;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.data.DataSource;
import haxe.ui.data.transformation.NativeTypeTransformer;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.events.ScrollEvent;
import haxe.ui.geom.Rectangle;
import haxe.ui.layouts.LayoutFactory;
import haxe.ui.layouts.VerticalVirtualLayout;
import haxe.ui.util.Variant;

@:composite(Events, Builder, Layout)
class TableView extends ScrollView implements IDataComponent implements IVirtualContainer {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(DataSourceBehaviour)                            public var dataSource:DataSource<Dynamic>;
    @:behaviour(LayoutBehaviour, -1)                            public var itemWidth:Float;
    @:behaviour(LayoutBehaviour, -1)                            public var itemHeight:Float;
    @:behaviour(LayoutBehaviour, -1)                            public var itemCount:Int;
    @:behaviour(LayoutBehaviour, false)                         public var variableItemSize:Bool;
    @:behaviour(SelectedIndexBehaviour, -1)                     public var selectedIndex:Int;
    @:behaviour(SelectedItemBehaviour)                          public var selectedItem:Dynamic;
    @:behaviour(SelectedIndicesBehaviour)                       public var selectedIndices:Array<Int>;
    @:behaviour(SelectedItemsBehaviour)                         public var selectedItems:Array<Dynamic>;
    @:behaviour(SelectionModeBehaviour, SelectionMode.ONE_ITEM) public var selectionMode:SelectionMode;
    @:behaviour(DefaultBehaviour, 500)                          public var longPressSelectionTime:Int;  //ms

    //TODO - error with Behaviour
    private var _itemRendererFunction:ItemRendererFunction4;
    public var itemRendererFunction(get, set):ItemRendererFunction4;
    private function get_itemRendererFunction():ItemRendererFunction4 {
        return _itemRendererFunction;
    }
    private function set_itemRendererFunction(value:ItemRendererFunction4):ItemRendererFunction4 {
        if (_itemRendererFunction != value) {
            _itemRendererFunction = value;
            invalidateComponentLayout();
        }

        return value;
    }

    private var _itemRendererClass:Class<ItemRenderer>;
    public var itemRendererClass(get, set):Class<ItemRenderer>;
    private function get_itemRendererClass():Class<ItemRenderer> {
        return _itemRendererClass;
    }
    private function set_itemRendererClass(value:Class<ItemRenderer>):Class<ItemRenderer> {
        if (_itemRendererClass != value) {
            _itemRendererClass = value;
            invalidateComponentLayout();
        }

        return value;
    }

    private var _itemRenderer:ItemRenderer;
    public var itemRenderer(get, set):ItemRenderer;
    private function get_itemRenderer():ItemRenderer {
        return _itemRenderer;
    }
    private function set_itemRenderer(value:ItemRenderer):ItemRenderer {
        if (_itemRenderer != value) {
            _itemRenderer = value;
            invalidateComponentLayout();
        }

        return value;
    }
}

@:dox(hide) @:noCompletion
typedef ItemRendererFunction4 = Dynamic->Int->Class<ItemRenderer>;    //(data, index):Class<ItemRenderer>

private class CompoundItemRenderer extends ItemRenderer {
    public function new() {
        super();
        this.layout = LayoutFactory.createFromName("horizontal");
        this.styleString = "spacing: 2px;";
        removeClass("itemrenderer");
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Events extends ScrollViewEvents {
    private var _tableview:TableView;

    public function new(tableview:TableView) {
        super(tableview);
        //tableview.clip = true;
        _tableview = tableview;
    }

    public override function register() {
        super.register();
        registerEvent(ScrollEvent.CHANGE, onScrollChange);
        registerEvent(UIEvent.RENDERER_CREATED, onRendererCreated);
        registerEvent(UIEvent.RENDERER_DESTROYED, onRendererDestroyed);
    }
    
    public override function unregister() {
        super.unregister();
        unregisterEvent(ScrollEvent.CHANGE, onScrollChange);
        unregisterEvent(UIEvent.RENDERER_CREATED, onRendererCreated);
        unregisterEvent(UIEvent.RENDERER_DESTROYED, onRendererDestroyed);
    }
    
    private function onScrollChange(e:ScrollEvent):Void {
        _tableview.invalidateComponentLayout();
    }


    private function onRendererCreated(e:UIEvent):Void {
        var instance:ItemRenderer = cast(e.data, ItemRenderer);
        instance.registerEvent(MouseEvent.CLICK, onRendererClick);
        if (_tableview.selectedIndices.indexOf(instance.itemIndex) != -1) {
            instance.addClass(":selected", true, true);
        }
    }

    private function onRendererDestroyed(e:UIEvent) {
        var instance:ItemRenderer = cast(e.data, ItemRenderer);
        instance.unregisterEvent(MouseEvent.CLICK, onRendererClick);
        if (_tableview.selectedIndices.indexOf(instance.itemIndex) != -1) {
            instance.removeClass(":selected", true, true);
        }
    }

    private override function onContainerEventsStatusChanged() {
        super.onContainerEventsStatusChanged();
        if (_containerEventsPaused == true) {
            _tableview.findComponent("tableview-contents", Component, true, "css").removeClass(":hover", true, true);
        } else if (_lastMousePos != null) {
            /* TODO: may be ill concieved, doesnt look good on mobile
            var items = _tableview.findComponentsUnderPoint(_lastMousePos.x, _lastMousePos.y, ItemRenderer);
            for (i in items) {
                i.addClass(":hover", true, true);
            }
            */
        }
    }
    
    private function onRendererClick(e:MouseEvent):Void {
        var components = e.target.findComponentsUnderPoint(e.screenX, e.screenY);
        for (component in components) {
            if (Std.is(component, InteractiveComponent)) {
                return;
            }
        }

        var renderer:ItemRenderer = cast(e.target, ItemRenderer);
        _tableview.selectedIndex = renderer.itemIndex;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends ScrollViewBuilder {
    private var _tableview:TableView;
    private var _header:Header;

    public function new(tableview:TableView) {
        super(tableview);
        _tableview = tableview;
    }

    public override function create() {
        createContentContainer(_tableview.virtual ? "absolute" : "vertical");
    }

    public override function onInitialize() {
        if (_header == null) {
            return;
        }
        if (_tableview.itemRenderer == null) {
            buildDefaultRenderer();
        } else {
            fillExistingRenderer();
        }
    }

    public override function onReady() {
        if (_header == null) {
            return;
        }
        if (_tableview.itemRenderer == null) {
            buildDefaultRenderer();
        } else {
            fillExistingRenderer();
        }
        
        _component.invalidateComponentLayout();
    }
    
    private override function createContentContainer(layoutName:String) {
        if (_contents == null) {
            super.createContentContainer(layoutName);
            _contents.addClass("tableview-contents");
        }
    }
    
    public override function addComponent(child:Component):Component {
        var r = null;
        if (Std.is(child, ItemRenderer)) {
            var itemRenderer = _tableview.itemRenderer;
            if (itemRenderer == null) {
                itemRenderer = new CompoundItemRenderer();
                _tableview.itemRenderer = itemRenderer;
            }
            itemRenderer.addComponent(child);
            
            return child;
        } else if (Std.is(child, Header)) {
            _header = cast(child, Header);
            
            /*
            if (_tableview.itemRenderer == null) {
                buildDefaultRenderer();
            } else {
                fillExistingRenderer();
            }
            */
            
            r = null;
        } else {
            r = super.addComponent(child);
        }
        return r;
    }
    
    public function buildDefaultRenderer() {
        var r = new CompoundItemRenderer();
        if (_header != null) {
            for (column in _header.childComponents) {
                var itemRenderer = new ItemRenderer();
                var label = new Label();
                label.id = column.id;
                label.verticalAlign = "center";
                itemRenderer.addComponent(label);
                r.addComponent(itemRenderer);
            }
        }
        _tableview.itemRenderer = r;
    }
    
    public function fillExistingRenderer() {
        for (column in _header.childComponents) {
            var existing = _tableview.itemRenderer.findComponent(column.id, ItemRenderer, true);
            if (existing == null) {
                var itemRenderer = new ItemRenderer();
                var label = new Label();
                label.id = column.id;
                label.verticalAlign = "center";
                itemRenderer.addComponent(label);
                _tableview.itemRenderer.addComponent(itemRenderer);
            }
        }
    }
    
    private override function verticalConstraintModifier():Float {
        if (_header == null || _tableview.virtual == true) {
            return 0;
        }

        return _header.height;
    }
    
    public override function onVirtualChanged() {
        _contents.layoutName = _tableview.virtual ? "absolute" : "vertical";
    }
    
    private override function get_virtualHorizontal():Bool {
        return false;
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
private class Layout extends VerticalVirtualLayout {
    private override function itemClass(index:Int, data:Dynamic):Class<ItemRenderer> {
        return CompoundItemRenderer;
    }
    
    public override function repositionChildren() {
        super.repositionChildren();

        var header = findComponent(Header, true);
        if (header == null) {
            return;
        }
        
        header.left = paddingLeft;
        header.top = paddingTop;
        var rc:Rectangle = new Rectangle(cast(_component, ScrollView).hscrollPos + 1, 1, usableWidth, header.height);
        header.componentClipRect = rc;
        
        var data = findComponent("tableview-contents", Box, true, "css");
        if (data != null) {
            for (item in data.childComponents) {
                var biggest:Float = 0;
                for (column in header.childComponents) {
                    var itemRenderer = item.findComponent(column.id, Component);
                    if (itemRenderer != null && Std.is(itemRenderer, ItemRenderer) == false) {
                        itemRenderer = itemRenderer.findAncestor(ItemRenderer);
                    }
                    if (itemRenderer != null) {
                        itemRenderer.percentWidth = null;
                        itemRenderer.width = column.width - item.layout.horizontalSpacing;
                        if (itemRenderer.height > biggest) {
                            biggest = itemRenderer.componentHeight;
                        }
                    }
                }
                data.componentWidth = item.width;
                /*
                if (biggest != 0) { // might not be a great idea - maybe rethink
                    for (column in header.childComponents) {
                        var itemRenderer = item.findComponent(column.id, Component).findAncestor(ItemRenderer);
                        if (itemRenderer != null) {
                            //trace(biggest);
                            itemRenderer.height = biggest;
                        }
                    }
                }
                */
            }
            
            data.left = paddingLeft;
            data.top = header.top + header.height;
        }
    }
    
    private override function verticalConstraintModifier():Float {
        var header = findComponent(Header, true);
        if (header == null) {
            return 0;
        }

        return header.height;
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class DataSourceBehaviour extends DataBehaviour {
    private var _firstPass:Bool = true; // may not have any any children at first, so a height of 1 causes loads of renderers to be created
    public override function set(value:Variant) {
        super.set(value);
        var dataSource:DataSource<Dynamic> = _value;
        if (dataSource != null) {
            dataSource.transformer = new NativeTypeTransformer();
            dataSource.onChange = function() {
                _component.invalidateComponentLayout();
                if (_firstPass == true) {
                    _component.syncComponentValidation();
                    _firstPass = false;
                    _component.invalidateComponentLayout();
                }
                BindingManager.instance.componentPropChanged(_component, "dataSource");
            }
            _component.invalidateComponentLayout();
        } else {
            _component.invalidateComponentLayout();
        }
    }
}

@:dox(hide) @:noCompletion
private class SelectedIndexBehaviour extends Behaviour {
    public override function get():Variant {
        var tableView:TableView = cast(_component, TableView);
        var selectedIndices:Array<Int> = tableView.selectedIndices;
        return selectedIndices != null && selectedIndices.length > 0 ? selectedIndices[selectedIndices.length-1] : -1;
    }

    public override function set(value:Variant) {
        var tableView:TableView = cast(_component, TableView);
        tableView.selectedIndices = value != -1 ? [value] : null;
    }
}

@:dox(hide) @:noCompletion
private class SelectedItemBehaviour extends Behaviour {
    public override function getDynamic():Dynamic {
        var tableView:TableView = cast(_component, TableView);
        var selectedIndices:Array<Int> = tableView.selectedIndices;
        return selectedIndices.length > 0 ? tableView.dataSource.get(selectedIndices[selectedIndices.length - 1]) : null;
    }

    public override function set(value:Variant) {
        var tableView:TableView = cast(_component, TableView);
        var index:Int = tableView.dataSource.indexOf(value);
        if (index != -1 && tableView.selectedIndices.indexOf(index) == -1) {
            tableView.selectedIndices = [index];
        }
    }
}

@:dox(hide) @:noCompletion
private class SelectedIndicesBehaviour extends DataBehaviour {
    public override function get():Variant {
        return _value.isNull ? [] : _value;
    }

    private override function validateData() {
        var tableView:TableView = cast(_component, TableView);
        var selectedIndices:Array<Int> = tableView.selectedIndices;
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        var itemToEnsure:ItemRenderer = null;
        for (child in contents.childComponents) {
            if (selectedIndices.indexOf(cast(child, ItemRenderer).itemIndex) != -1) {
                itemToEnsure = cast(child, ItemRenderer);
                child.addClass(":selected", true, true);
            } else {
                child.removeClass(":selected", true, true);
            }
        }

        if (itemToEnsure != null && tableView.virtual == false) {  // TODO: virtual scroll into view
            var vscroll:VerticalScroll = tableView.findComponent(VerticalScroll);
            if (vscroll != null) {
                var vpos:Float = vscroll.pos;
                var contents:Component = tableView.findComponent("tableview-contents", "css");
                if (itemToEnsure.top + itemToEnsure.height > vpos + contents.componentClipRect.height) {
                    vscroll.pos = ((itemToEnsure.top + itemToEnsure.height) - contents.componentClipRect.height);
                } else if (itemToEnsure.top < vpos) {
                    vscroll.pos = itemToEnsure.top;
                }
            }
        }
        
        if (tableView.selectedIndex != -1 && tableView.selectedIndices.length != 0) {
            _component.dispatch(new UIEvent(UIEvent.CHANGE));
        }
    }
}

@:dox(hide) @:noCompletion
private class SelectedItemsBehaviour extends Behaviour {
    public override function get():Variant {
        var tableView:TableView = cast(_component, TableView);
        var selectedIndices:Array<Int> = tableView.selectedIndices;
        if (selectedIndices != null && selectedIndices.length > 0) {
            var selectedItems:Array<Dynamic> = [];
            for (i in selectedIndices) {
                if ((i < 0) || (i >= tableView.dataSource.size)) {
                    continue;
                }
                var data:Dynamic = tableView.dataSource.get(i);
                selectedItems.push(data);
            }

            return selectedItems;
        } else {
            return [];
        }
    }

    public override function set(value:Variant) {
        var tableView:TableView = cast(_component, TableView);
        var selectedItems:Array<Dynamic> = value;
        if (selectedItems != null && selectedItems.length > 0) {
            var selectedIndices:Array<Int> = [];
            var index:Int;
            for (item in selectedItems) {
                if ((index = tableView.dataSource.indexOf(item)) != -1) {
                    selectedIndices.push(index);
                }
            }

            tableView.selectedIndices = selectedIndices;
        } else {
            tableView.selectedIndices = [];
        }
    }
}

@:dox(hide) @:noCompletion
private class SelectionModeBehaviour extends DataBehaviour {
    private override function validateData() {
        var tableView:TableView = cast(_component, TableView);
        var selectedIndices:Array<Int> = tableView.selectedIndices;
        if (selectedIndices.length == 0) {
            return;
        }

        var selectionMode:SelectionMode = cast _value;
        switch(selectionMode) {
            case SelectionMode.DISABLED:
                tableView.selectedIndices = null;

            case SelectionMode.ONE_ITEM:
                if (selectedIndices.length > 1) {
                    tableView.selectedIndices = [selectedIndices[0]];
                }

            default:
        }
    }
}