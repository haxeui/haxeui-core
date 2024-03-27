package haxe.ui.containers;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.data.DataSource;
import haxe.ui.events.UIEvent;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.layouts.LayoutFactory;
import haxe.ui.styles.Style;
import haxe.ui.util.Variant;

/**
 Base `Layout` that allows a container to specify an `icon`. How that icon resource is used depends on subclasses, like `TabView`
**/
@:dox(icon = "/icons/ui-panel.png")
@:composite(Builder, DefaultLayout)
class Box extends Component implements IDataComponent {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    /**
     The icon associated with this box component

     *Note*: this class itself does nothing special with this property and simply here to allow subclasses to make use
     of it should they want to
    **/
    @:clonable @:behaviour(DefaultBehaviour)                public var icon:Variant;
    @:clonable @:behaviour(DataSourceBehaviour)             public var dataSource:DataSource<Dynamic>;

    @:noCompletion private var _layoutName:String;
    @:clonable public var layoutName(get, set):String;
    private function get_layoutName():String {
        return _layoutName;
    }
    private function set_layoutName(value:String):String {
        if (_layoutName == value) {
            return value;
        }

        _layoutName = value;
        var l = LayoutFactory.createFromName(layoutName);
        if (l != null) {
            layout = l;
        }
        return value;
    }

    private var _itemRenderer:ItemRenderer;
    @:clonable public var itemRenderer(get, set):ItemRenderer;
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

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        if (_defaultLayoutClass == null) {
            _defaultLayoutClass = DefaultLayout;
        }
    }
    
    @:noCompletion private var _direction:String = null;
    private override function applyStyle(style:Style) {
        super.applyStyle(style);
        
        if (style.direction != null && style.direction != _direction) {
            _direction = style.direction;
            this.layout = LayoutFactory.createFromName(_direction);
        }
        if (style.layout != null) {
            layoutName = style.layout;
        }
    }
}

//***********************************************************************************************************
// Builder
//***********************************************************************************************************
private class Builder extends CompositeBuilder {
    private var _box:Box;
    public var hasDataSource:Bool; // we'll hold a flag for ease since the act of call .dataSource will create a default one (so ".dataSource == null" will always evaluate as false)

    public function new(box:Box) {
        super(box);
        _box = box;
    }

    @:access(haxe.ui.backend.ComponentImpl)
    public override function addComponent(child:Component):Component {
        if ((child is ItemRenderer) && _box.itemRenderer == null) {
            var builder:Builder = cast(_box._compositeBuilder, Builder);
            if (builder.hasDataSource) {
                _box.itemRenderer = cast(child, ItemRenderer);
                _box.itemRenderer.ready();
                _box.itemRenderer.handleVisibility(false);
                _box.invalidateComponentData();
                return child;
            }
        }
        return super.addComponent(child);
    }

    public override function validateComponentData() {
        syncChildren();
    }

    @:access(haxe.ui.backend.ComponentImpl)
    private function syncChildren() {
        if (!hasDataSource) {
            return;
        }

        var dataSource:DataSource<Dynamic> = _box.dataSource;
        var itemRenderer:ItemRenderer = _box.itemRenderer;
        if (itemRenderer == null) {
            itemRenderer = _box.findComponent(ItemRenderer);
            if (itemRenderer == null) {
                return;
            }

            _box.itemRenderer = itemRenderer;
            _box.itemRenderer.includeInLayout = false;
            _box.itemRenderer.ready();
            _box.itemRenderer.handleVisibility(false);
        }

        for (i in 0...dataSource.size) {
            var item = dataSource.get(i);
            var renderer = findRenderer(item);
            if (renderer == null) {
                renderer = itemRenderer.cloneComponent();
                _box.addComponent(renderer);
            }
            renderer.itemIndex = i;
            _box.setComponentIndex(renderer, i);
            renderer.data = item;
        }

        for (child in _component.findComponents(ItemRenderer)) {
            if (child == _box.itemRenderer) {
                continue;
            }
            if (dataSource.indexOf(child.data) == -1) {
                _box.removeComponent(child);
            }
        }
    }

    private function findRenderer(data:Dynamic):ItemRenderer {
        for (child in _component.findComponents(ItemRenderer)) {
            if (child.data == data) {
                return child;
            }
        }
        return null;
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class DataSourceBehaviour extends DataBehaviour {
    private var _box:Box;

    public function new(box:Box) {
        super(box);
        _box = box;
    }

    public override function set(value:Variant) {
        super.set(value);
        var dataSource:DataSource<Dynamic> = _value;
        var builder:Builder = cast(_box._compositeBuilder, Builder);
        if (dataSource != null) {
            builder.hasDataSource = true;
            dataSource.onDataSourceChange = function() {
                _box.invalidateComponentData();
            }
        } else {
            builder.hasDataSource = false;
            _box.removeAllComponents();
        }
        _box.invalidateComponentData();
    }

    public override function get():Variant {
        if (_value == null || _value.isNull) {
            _value = new ArrayDataSource<Dynamic>();
            var dataSource:DataSource<Dynamic> = _value;
            var builder:Builder = cast(_box._compositeBuilder, Builder);
            builder.hasDataSource = true;
            dataSource.onDataSourceChange = function() {
                _box.invalidateComponentData();
            }
        }
        return _value;
    }
}
