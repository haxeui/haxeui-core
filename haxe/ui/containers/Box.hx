package haxe.ui.containers;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.core.Component;
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

private class Builder extends CompositeBuilder {
    private var _box:Box;

    public function new(box:Box) {
        super(box);
        _box = box;
    }

    @:access(haxe.ui.backend.ComponentImpl)
    public override function addComponent(child:Component):Component {
        var r = null;
        if ((child is ItemRenderer) && _box.itemRenderer == null) {
            _box.itemRenderer = cast(child, ItemRenderer);
            _box.itemRenderer.ready();
            _box.itemRenderer.handleVisibility(false);
            r = child;
        } else {
            r = super.addComponent(child);
        }
        return r;
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class DataSourceBehaviour extends DataBehaviour {
    private var _box:Box;

    public function new(box:Box) {
        super(box);
        _box = box;
    }

    public override function set(value:Variant) {
        super.set(value);
        var dataSource:DataSource<Dynamic> = _value;
        if (dataSource != null) {
            dataSource.onDataSourceChange = function() {
                syncChildren();
            }
        }
        syncChildren();
    }

    public override function get():Variant {
        if (_value == null || _value.isNull) {
            _value = new ArrayDataSource<Dynamic>();
            var dataSource:DataSource<Dynamic> = _value;
            dataSource.onDataSourceChange = function() {
                syncChildren();
            }
        }
        return _value;
    }

    private function syncChildren() { // can probably be more efficient here, but doesnt seem to cause any obvious perf problem
                                      // wouldnt hurt to just reuse item renderers though rather than destroying and creating them
        var dataSource:DataSource<Dynamic> = _value;
        for (i in 0...dataSource.size) {
            var item = dataSource.get(i);
            var renderer = findRenderer(item);
            if (renderer == null) {
                renderer = _box.itemRenderer.cloneComponent();
                _box.addComponent(renderer);
            }
            _box.setComponentIndex(renderer, i);
            renderer.data = item;
        }
        var childrenToRemove = [];
        for (child in _component.findComponents(ItemRenderer)) {
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
