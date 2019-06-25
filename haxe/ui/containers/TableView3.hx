package haxe.ui.containers;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.LayoutBehaviour;
import haxe.ui.binding.BindingManager;
import haxe.ui.components.Label;
import haxe.ui.components.VerticalScroll;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.ScrollView.ScrollViewBuilder;
import haxe.ui.core.Component;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.data.DataSource;
import haxe.ui.data.transformation.NativeTypeTransformer;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.ScrollEvent;
import haxe.ui.geom.Rectangle;
import haxe.ui.layouts.LayoutFactory;
import haxe.ui.layouts.VerticalVirtualLayout;
import haxe.ui.util.Variant;

@:composite(Events, Builder, Layout)
class TableView3 extends ScrollView implements IDataComponent implements IVirtualContainer {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(DataSourceBehaviour)                            public var dataSource:DataSource<Dynamic>;
    @:behaviour(LayoutBehaviour, -1)                            public var itemWidth:Float;
    @:behaviour(LayoutBehaviour, -1)                            public var itemHeight:Float;
    @:behaviour(LayoutBehaviour, -1)                            public var itemCount:Int;
    @:behaviour(LayoutBehaviour, false)                         public var variableItemSize:Bool;

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
    
    public override function addComponent(child:Component):Component {
        if (childComponents.length > 1) {
            var c = new Component();
            c.styleString = "width:2px;color:black;height:10px";
            //super.addComponent(c);
        }
        return super.addComponent(child);
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Events extends ScrollViewEvents {
    private var _tableview:TableView3;

    public function new(tableview:TableView3) {
        super(tableview);
        //tableview.clip = true;
        _tableview = tableview;
    }

    public override function register() {
        super.register();
        registerEvent(ScrollEvent.CHANGE, onScrollChange);
        //registerEvent(UIEvent.RENDERER_CREATED, onRendererCreated);
        //registerEvent(UIEvent.RENDERER_DESTROYED, onRendererDestroyed);
    }
    
    public override function unregister() {
        super.unregister();
        unregisterEvent(ScrollEvent.CHANGE, onScrollChange);
        //unregisterEvent(UIEvent.RENDERER_CREATED, onRendererCreated);
        //unregisterEvent(UIEvent.RENDERER_DESTROYED, onRendererDestroyed);
    }
    
    private function onScrollChange(e:ScrollEvent):Void {
        _tableview.invalidateComponentLayout();
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends ScrollViewBuilder {
    private var _tableview:TableView3;
    private var _header:Header;

    public function new(tableview:TableView3) {
        super(tableview);
        _tableview = tableview;
    }

    public override function create() {
        createContentContainer(_tableview.virtual ? "absolute" : "vertical");
    }

    public override function onInitialize() {
        if (_tableview.itemRenderer == null) {
            buildDefaultRenderer();
        } else {
            fillExistingRenderer();
        }
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
            r = null;
        } else {
            r = super.addComponent(child);
        }
        return r;
    }
    
    public function buildDefaultRenderer() {
        var r = new CompoundItemRenderer();
        for (column in _header.childComponents) {
            var itemRenderer = new ItemRenderer();
            var label = new Label();
            label.id = column.id;
            label.verticalAlign = "center";
            itemRenderer.addComponent(label);
            r.addComponent(itemRenderer);
        }
        _tableview.itemRenderer = r;
    }
    
    public function fillExistingRenderer() {
        for (column in _header.childComponents) {
            var existing = _tableview.itemRenderer.findComponent(column.id, ItemRenderer, true);
            if (existing == null) {
                var label = new Label();
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
    public override function repositionChildren() {
        super.repositionChildren();

        var header = findComponent(Header, true);
        if (header == null) {
            return;
        }
        
        /*
        header.left = -cast(_component, ScrollView).hscrollPos + paddingLeft - 1;
        */
        header.left = paddingLeft;
        header.top = paddingTop;
        var rc:Rectangle = new Rectangle(cast(_component, ScrollView).hscrollPos + 1, 1, usableWidth, header.height);
        header.componentClipRect = rc;
        
        var data = findComponent("tableview-contents", Box, true, "css");
        if (data != null) {
            for (item in data.childComponents) {
                var biggest:Float = 0;
                for (column in header.childComponents) {
                    var itemRenderer = item.findComponent(column.id, Component).findAncestor(ItemRenderer);
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
    
    public override function resizeChildren() {
        super.resizeChildren();
        
        var header = findComponent(Header, true);
        if (header != null) {
            var vscroll = findComponent(VerticalScroll);
            if (vscroll == null) {
                //header.componentWidth += 2;
            } else {
                //header.componentWidth += 1;
            }
            //header.width += 1;
        }
    }
    
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class DataSourceBehaviour extends DataBehaviour {
    public override function set(value:Variant) {
        super.set(value);
        var dataSource:DataSource<Dynamic> = _value;
        if (dataSource != null) {
            dataSource.transformer = new NativeTypeTransformer();
            dataSource.onChange = function() {
                _component.invalidateComponentLayout();
                BindingManager.instance.componentPropChanged(_component, "dataSource");
            }
        }
        _component.invalidateComponentLayout();
    }
}

