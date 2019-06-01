package haxe.ui.containers;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.LayoutBehaviour;
import haxe.ui.binding.BindingManager;
import haxe.ui.components.Label;
import haxe.ui.containers.ScrollView.ScrollViewBuilder;
import haxe.ui.containers.ScrollView.ScrollViewEvents;
import haxe.ui.core.BasicItemRenderer;
import haxe.ui.core.Component;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.data.DataSource;
import haxe.ui.data.transformation.NativeTypeTransformer;
import haxe.ui.events.ScrollEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.layouts.LayoutFactory;
import haxe.ui.layouts.ScrollViewLayout;
import haxe.ui.layouts.VerticalVirtualLayout;
import haxe.ui.util.Variant;

@:composite(Events, Builder, Layout)
class TableView2 extends ScrollView implements IDataComponent implements IVirtualContainer {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(DataSourceBehaviour)                            public var dataSource:DataSource<Dynamic>;
    @:behaviour(LayoutBehaviour, -1)                            public var itemWidth:Float;
    @:behaviour(LayoutBehaviour, -1)                            public var itemCount:Int;
    @:behaviour(LayoutBehaviour, -1)                            public var itemHeight:Float;
    @:behaviour(LayoutBehaviour, false)                         public var variableItemSize:Bool;

    
    //TODO - error with Behaviour
    private var _itemRendererFunction:ItemRendererFunction3;
    public var itemRendererFunction(get, set):ItemRendererFunction3;
    private function get_itemRendererFunction():ItemRendererFunction3 {
        return _itemRendererFunction;
    }
    private function set_itemRendererFunction(value:ItemRendererFunction3):ItemRendererFunction3 {
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

    
    
    
    /*
    private var _rendererPool:Array<ItemRenderer> = [];
    public function refreshNonVirtualData() {
        if (dataSource == null) {
            return;
        }
        
        var dataSource:DataSource<Dynamic> = dataSource;
        
        
        var contents:Component = cast(this._compositeBuilder, Builder).tableDataContainer;// .contents;
        
        
        for (n in 0...dataSource.size) {
            var data:Dynamic = dataSource.get(n);
            var item:ItemRenderer = null;
            if (n < contents.childComponents.length) {
                item = cast(contents.childComponents[n], ItemRenderer);
                if (item.data == data) {
                    continue;
                }

                var cls = itemClass(n, data);
                if (Std.is(item, cls)) {
                } else {
                    removeRenderer(item);
                    item = getRenderer(cls, n);
                    contents.addComponentAt(item, n);
                }
            } else {
                var cls = itemClass(n, data);
                item = getRenderer(cls, n);
                contents.addComponent(item);
            }

            var className:String = n % 2 == 0 ? "even" : "odd";
            if (!item.hasClass(className)) {
                var inverseClassName = n % 2 == 0 ? "odd" : "even";
                item.removeClass(inverseClassName);
                item.addClass(className);
            }

            item.itemIndex = n;
            item.data = data;
        }

        while (dataSource.size < contents.childComponents.length) {
            var item:ItemRenderer = cast contents.childComponents[contents.childComponents.length - 1];
            removeRenderer(item);    // remove last
        }
    }
    
    private function itemClass(index:Int, data:Dynamic):Class<ItemRenderer> {
        var comp:IVirtualContainer = cast(this, IVirtualContainer);
        if (comp.itemRendererFunction != null) {
            return comp.itemRendererFunction(data, index);
        } else if (comp.itemRendererClass != null) {
            return comp.itemRendererClass;
        } else if (comp.itemRenderer != null) {
            return Type.getClass(comp.itemRenderer);
        } else {
            return TempItemRenderer;
        }
    }

    private function getRenderer(cls:Class<ItemRenderer>, index:Int):ItemRenderer {
        var instance:ItemRenderer = null;
        var comp:IVirtualContainer = cast(this, IVirtualContainer);
        if (comp.virtual == true) {
            for (i in 0..._rendererPool.length) {
                var renderer = _rendererPool[i];
                if (Std.is(renderer, cls)) {
                    _rendererPool.splice(i, 1);
                    instance = renderer;
                    break;
                }
            }
        }

        if (instance == null) {
            if (comp.itemRenderer != null && Type.getClass(comp.itemRenderer) == cls) {
                instance = comp.itemRenderer.cloneComponent();
            } else {
                instance = Type.createInstance(cls, []);
            }
        }

        instance.itemIndex = index;
        if (this.hasEvent(UIEvent.RENDERER_CREATED)) {
            this.dispatch(new UIEvent(UIEvent.RENDERER_CREATED, instance));
        }

        return cast(instance, ItemRenderer);
    }

    private function removeRenderer(renderer:ItemRenderer, dispose:Bool = true) {
        this.removeComponent(renderer, dispose);

        var comp:IVirtualContainer = cast(this, IVirtualContainer);
        if (comp.virtual == true) {
            _rendererPool.push(cast(renderer, ItemRenderer));
        }

        if (this.hasEvent(UIEvent.RENDERER_DESTROYED)) {
            this.dispatch(new UIEvent(UIEvent.RENDERER_DESTROYED, renderer));
        }

        renderer.itemIndex = -1;
    }
    */
}

@:dox(hide) @:noCompletion
typedef ItemRendererFunction3 = Dynamic->Int->Class<ItemRenderer>;    //(data, index):Class<ItemRenderer>



//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.Builder)
private class Events extends ScrollViewEvents {
    private var _tableview:TableView2;

    public function new(tableview:TableView2) {
        super(tableview);
        _tableview = tableview;
    }

    public override function register() {
        super.register();
        registerEvent(ScrollEvent.CHANGE, onScrollChange);
        /*
        registerEvent(UIEvent.RENDERER_CREATED, onRendererCreated);
        registerEvent(UIEvent.RENDERER_DESTROYED, onRendererDestroyed);
        */
    }
    
    public override function unregister() {
        super.unregister();
        unregisterEvent(ScrollEvent.CHANGE, onScrollChange);
        /*
        unregisterEvent(UIEvent.RENDERER_CREATED, onRendererCreated);
        unregisterEvent(UIEvent.RENDERER_DESTROYED, onRendererDestroyed);
        */
    }
    
    /*
    private override function onHScroll(event:UIEvent) {
        super.onHScroll(event);
        var builder = cast(_scrollview._compositeBuilder, Builder);
        _tableview.invalidateComponentLayout();
    }
    */
    
    
    private function onScrollChange(e:ScrollEvent):Void {
        trace(_tableview.vscrollPos);
        _tableview.invalidateComponentLayout();
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends ScrollViewBuilder {
    public var tableDataContainer:Box;
    
    private var _tableview:TableView2;
    private var _header:Header = null;
    
    public function new(tableview:TableView2) {
        super(tableview);
        _tableview = tableview;
        _tableview.clip = true;
    }
    
    public override function create() {
        createContentContainer("absolute");
        tableDataContainer = new Box();
        tableDataContainer.addClass("tableview-data");
        tableDataContainer.layoutName = _tableview.virtual ? "absolute" : "vertical";
        tableDataContainer.styleString = "spacing: 0";
        _contents.addComponent(tableDataContainer);
        _contents.styleString = "spacing: 0";
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
    
    private override function verticalConstraintModifier():Float {
        if (_header == null || _tableview.virtual == true) {
            return 0;
        }

        return _header.height;
    }
    
    public override function addComponent(child:Component):Component {
        if (Std.is(child, Header) == true) {
            _header = cast(child, Header);
            //buildDefaultRenderer();
            return null;
        } else if (Std.is(child, ItemRenderer)) {
            var itemRenderer = _tableview.itemRenderer;
            if (itemRenderer == null) {
                itemRenderer = new CompositeItemRenderer();
                _tableview.itemRenderer = itemRenderer;
            }
            itemRenderer.addComponent(child);
            
            return child;
        }
        return super.addComponent(child);
    }
    
    public function buildDefaultRenderer() {
        var r = new CompositeItemRenderer();
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
    
    public override function onVirtualChanged() {
        tableDataContainer.layoutName = _tableview.virtual ? "absolute" : "vertical";
    }
}

private class CompositeItemRenderer extends ItemRenderer {
    public function new() {
        super();
        this.layout = LayoutFactory.createFromName("horizontal");
        this.styleString = "spacing: 2px;";
        removeClass("itemrenderer");
    }
    
    public override function hasClass(name:String):Bool {
        if (name != "even" && name != "odd" && name != "itemrenderer") {
            return super.hasClass(name);
        }
        var b = false;
        for (child in childComponents) {
            b = b || child.hasClass(name);
        }
        return b;
    }
    
    public override function addClass(name:String, invalidate:Bool = true, recursive:Bool = false) {
        if (name != "even" && name != "odd" && name != "itemrenderer") {
            return super.addClass(name, invalidate, recursive);
        }
        for (child in childComponents) {
            child.addClass(name, invalidate, recursive);
        }
    }
    
    public override function removeClass(name:String, invalidate:Bool = true, recursive:Bool = false) {
        if (name != "even" && name != "odd" && name != "itemrenderer") {
            return super.addClass(name, invalidate, recursive);
        }
        for (child in childComponents) {
            child.removeClass(name, invalidate, recursive);
        }
    }
}

//***********************************************************************************************************
// Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Layout extends VerticalVirtualLayout {
    /*
    public override function refresh() {
        cast(_component, TableView2).refreshNonVirtualData();

        super.refresh();
    }
    */
    
    private override function get_itemHeight():Float {
        return 25;
    }
    
    private override function get_itemCount():Int {
        return 11;
    }
    
    private override function get_contents():Component {
        if (contents == null) {
            contents = findComponent("tableview-data", true, "css");
        }

        return contents;
    }
    
    public override function repositionChildren() {
        super.repositionChildren();
        
        var header = findComponent(Header, true);
        header.left = -cast(_component, ScrollView).hscrollPos;
        
        var data = findComponent("tableview-data", Box, true, "css");
        if (data != null) {
            for (item in data.childComponents) {
                var biggest:Float = 0;
                for (column in header.childComponents) {
                    var itemRenderer = item.findComponent(column.id, Component).findAncestor(ItemRenderer);
                    if (itemRenderer != null) {
                        itemRenderer.percentWidth = null;
                        itemRenderer.width = column.width - 2;
                        if (itemRenderer.height > biggest) {
                            biggest = itemRenderer.height;
                        }
                    }
                }
                if (biggest != 0) { // might not be a great idea - maybe rethink
                    for (column in header.childComponents) {
                        var itemRenderer = item.findComponent(column.id, Component).findAncestor(ItemRenderer);
                        if (itemRenderer != null) {
                            //itemRenderer.height = biggest;
                        }
                    }
                }
            }
            data.left = 0;
            data.top = header.height - 1;
        }
    }
    
    /*
    public override function resizeChildren() {
        super.resizeChildren();
        
        var header = findComponent(Header, true);
        var data = findComponent("tableview-data", VBox, true, "css");
        //data.height = usableHeight;
    }
    */
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