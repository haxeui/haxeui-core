package haxe.ui.containers;

import haxe.ui.constants.SelectionMode;
import haxe.ui.containers.ScrollView2;
import haxe.ui.containers.ScrollView2.ScrollViewBuilder;
import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.DataBehaviour;
import haxe.ui.core.DefaultBehaviour;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.core.LayoutBehaviour;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.ScrollEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.data.DataSource;
import haxe.ui.data.transformation.NativeTypeTransformer;
import haxe.ui.layouts.VerticalVirtualLayout;
import haxe.ui.util.Variant;

@:composite(ListViewEvents, ListViewBuilder, VerticalVirtualLayout)
class ListView2 extends ScrollView2 implements IDataComponent implements IVirtualContainer {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(DataSourceBehaviour)                            public var dataSource:DataSource<Dynamic>;
    @:behaviour(LayoutBehaviour, 30)                            public var itemWidth:Float;
    @:behaviour(LayoutBehaviour, -1)                            public var itemHeight:Float;
    @:behaviour(LayoutBehaviour, false)                         public var variableItemSize:Bool;
    @:behaviour(SelectedIndexBehaviour, -1)                     public var selectedIndex:Int;
    @:behaviour(SelectedItemBehaviour)                          public var selectedItem:Dynamic;
    @:behaviour(SelectedIndicesBehaviour)                       public var selectedIndices:Array<Int>;
    @:behaviour(SelectedItemsBehaviour)                         public var selectedItems:Array<Dynamic>;
    @:behaviour(SelectionModeBehaviour, SelectionMode.ONE_ITEM) public var selectionMode:SelectionMode;
    @:behaviour(DefaultBehaviour, 500)                          public var longPressSelectionTime:Int;  //ms

    //TODO - error with Behaviour
    private var _itemRendererFunction:ItemRendererFunction2;
    public var itemRendererFunction(get, set):ItemRendererFunction2;
    private function get_itemRendererFunction():ItemRendererFunction2 {
        return _itemRendererFunction;
    }
    private function set_itemRendererFunction(value:ItemRendererFunction2):ItemRendererFunction2 {
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

typedef ItemRendererFunction2 = Dynamic->Int->Class<ItemRenderer>;    //(data, index):Class<ItemRenderer>

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class ListViewEvents extends ScrollViewEvents {
    private var _listview:ListView2;

    public function new(listview:ListView2) {
        super(listview);
        _listview = listview;
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
        _listview.invalidateComponentLayout();
    }

    private function onRendererCreated(e:UIEvent):Void {
        var instance:ItemRenderer = cast(e.data, ItemRenderer);
        instance.registerEvent(MouseEvent.CLICK, onRendererClick);
        if(_listview.selectedIndices.indexOf(instance.itemIndex) != -1) {
            instance.addClass(":selected", true, true);
        }
    }

    private function onRendererDestroyed(e:UIEvent) {
        var instance:ItemRenderer = cast(e.data, ItemRenderer);
        instance.unregisterEvent(MouseEvent.CLICK, onRendererClick);
        if(_listview.selectedIndices.indexOf(instance.itemIndex) != -1) {
            instance.removeClass(":selected", true, true);
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
        switch(_listview.selectionMode) {
            case SelectionMode.DISABLED:

            case SelectionMode.ONE_ITEM:
                _listview.selectedIndex = renderer.itemIndex;

            case SelectionMode.ONE_ITEM_REPEATED:
                _listview.selectedIndices = [renderer.itemIndex];

            case SelectionMode.MULTIPLE_CTRL:
                if (e.ctrlKey == true) {
                    toggleSelection(renderer);
                }

            case SelectionMode.MULTIPLE_SHIFT:
                if (e.shiftKey == true) {
                    toggleSelection(renderer);
                }
            case SelectionMode.MULTIPLE_LONG_PRESS:
                //TODO

        }
    }

    private function toggleSelection(renderer:ItemRenderer) {
        var itemIndex:Int = renderer.itemIndex;
        var selectedIndices = _listview.selectedIndices.copy();
        var index:Int;
        if ((index = selectedIndices.indexOf(itemIndex)) == -1) {
            selectedIndices.push(itemIndex);
        } else {
            selectedIndices.splice(index, 1);
        }
        _listview.selectedIndices = selectedIndices;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class ListViewBuilder extends ScrollViewBuilder {
    private var _listview:ListView2;

    public function new(listview:ListView2) {
        super(listview);
        _listview = listview;
    }

    public override function create() {
        createContentContainer(_listview.virtual ? "absolute" : "vertical");
    }

    private override function createContentContainer(layoutName:String) {
        if (_contents == null) {
            super.createContentContainer(layoutName);
            _contents.addClass("listview-contents");
        }
    }
    
    public override function addComponent(child:Component):Component {
        var r = null;
        if (Std.is(child, ItemRenderer) && (_listview.itemRenderer == null && _listview.itemRendererFunction == null && _listview.itemRendererClass == null)) {
            _listview.itemRenderer = cast(child, ItemRenderer);
            r = child;
        } else {
            r = super.addComponent(child);
        }
        return r;
    }
    
    public override function onVirtualChanged() {
        _contents.layoutName = _listview.virtual ? "absolute" : "vertical";
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
            dataSource.onChange = _component.invalidateComponentData;
        }
    }
}

@:dox(hide) @:noCompletion
private class SelectedIndexBehaviour extends Behaviour {
    public override function get():Variant {
        var listView:ListView2 = cast(_component, ListView2);
        var selectedIndices:Array<Int> = listView.selectedIndices;
        return selectedIndices != null && selectedIndices.length > 0 ? selectedIndices[selectedIndices.length-1] : -1;
    }

    public override function set(value:Variant) {
        var listView:ListView2 = cast(_component, ListView2);
        listView.selectedIndices = [value];
    }
}

@:dox(hide) @:noCompletion
private class SelectedItemBehaviour extends Behaviour {
    public override function get():Variant {
        var listView:ListView2 = cast(_component, ListView2);
        var selectedIndices:Array<Int> = listView.selectedIndices;
        return selectedIndices.length > 0 ? listView.dataSource.get(selectedIndices[selectedIndices.length - 1]) : null;
    }

    public override function set(value:Variant) {
        var listView:ListView2 = cast(_component, ListView2);
        var index:Int = listView.dataSource.indexOf(value);
        if (index != -1 && listView.selectedIndices.indexOf(index) == -1) {
            listView.selectedIndices = [index];
        }
    }
}

@:dox(hide) @:noCompletion
private class SelectedIndicesBehaviour extends DataBehaviour {
    public override function get():Variant {
        return _value.isNull ? [] : _value;
    }

    private override function validateData() {
        var listView:ListView2 = cast(_component, ListView2);
        var selectedIndices:Array<Int> = listView.selectedIndices;
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        for (child in contents.childComponents) {
            if (selectedIndices.indexOf(cast(child, ItemRenderer).itemIndex) != -1) {
                child.addClass(":selected", true, true);
            } else {
                child.removeClass(":selected", true, true);
            }
        }

        _component.dispatch(new UIEvent(UIEvent.CHANGE));
    }
}

@:dox(hide) @:noCompletion
private class SelectedItemsBehaviour extends Behaviour {
    public override function get():Variant {
        var listView:ListView2 = cast(_component, ListView2);
        var selectedIndices:Array<Int> = listView.selectedIndices;
        if (selectedIndices != null && selectedIndices.length > 0) {
            var selectedItems:Array<Dynamic> = [];
            for (i in 0...listView.dataSource.size) {
                var data:Dynamic = listView.dataSource.get(i);
                selectedItems.push(data);
            }

            return selectedItems;
        } else {
            return [];
        }
    }

    public override function set(value:Variant) {
        var listView:ListView2 = cast(_component, ListView2);
        var selectedItems:Array<Dynamic> = value;
        if (selectedItems != null && selectedItems.length > 0) {
            var selectedIndices:Array<Int> = [];
            var index:Int;
            for (item in selectedItems) {
                if ((index = listView.dataSource.indexOf(item)) != -1) {
                    selectedIndices.push(index);
                }
            }

            listView.selectedIndices = selectedIndices;
        } else {
            listView.selectedIndices = [];
        }
    }
}

@:dox(hide) @:noCompletion
private class SelectionModeBehaviour extends DataBehaviour {
    private override function validateData() {
        var listView:ListView2 = cast(_component, ListView2);
        var selectedIndices:Array<Int> = listView.selectedIndices;
        if (selectedIndices.length == 0) {
            return;
        }

        var selectionMode:SelectionMode = cast _value;
        switch(selectionMode) {
            case SelectionMode.DISABLED:
                listView.selectedIndices = null;

            case SelectionMode.ONE_ITEM:
                if (selectedIndices.length > 1) {
                    listView.selectedIndices = [selectedIndices[0]];
                }

            default:
        }
    }
}