package haxe.ui.containers;

import haxe.ui.core.ScrollEvent;
import haxe.ui.containers.ScrollView2.ScrollViewBuilder;
import haxe.ui.containers.ScrollView2;
import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.DataBehaviour;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.core.LayoutBehaviour;
import haxe.ui.core.UIEvent;
import haxe.ui.data.DataSource;
import haxe.ui.data.transformation.NativeTypeTransformer;
import haxe.ui.layouts.VerticalVirtualLayout;
import haxe.ui.util.Variant;

class ListView2 extends ScrollView2 implements IDataComponent implements IVirtualContainer {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(DataSourceBehaviour)                    public var dataSource:DataSource<Dynamic>;
    @:behaviour(LayoutBehaviour, 30)                    public var itemWidth:Float;
    @:behaviour(LayoutBehaviour, 30)                    public var itemHeight:Float;
    @:behaviour(LayoutBehaviour, false)                 public var variableItemSize:Bool;
    @:behaviour(SelectedIndexBehaviour, -1)             public var selectedIndex:Int;
    @:behaviour(SelectedItemBehaviour)                  public var selectedItem:Component;  //TODO :ItemRenderer - Error -> Variant should be ItemRenderer

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

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() { // TODO: remove this eventually, @:layout(...) or something
        super.createDefaults();
        _defaultLayout = new VerticalVirtualLayout();
    }

    private override function registerComposite() { // TODO: remove this eventually, @:composite(...) or something
        super.registerComposite();
        _compositeBuilderClass = ListViewBuilder;
    }
}

typedef ItemRendererFunction2 = Dynamic->Int->Class<ItemRenderer>;    //(data, index):Class<ItemRenderer>

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class ListViewEvents extends ScrollViewEvents {
    public function new(scrollview:ScrollView2) {
        super(scrollview);

        scrollview.registerEvent(ScrollEvent.CHANGE, function(e) {
            scrollview.invalidateComponentLayout();
        });
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:allow(haxe.ui.containers.ListView2)
@:access(haxe.ui.core.Component)
private class ListViewBuilder extends ScrollViewBuilder {
    private var _listview:ListView2;

    public function new(listview:ListView2) {
        super(listview);
        _listview = listview;
    }

    public override function create() {
        createContentContainer("absolute");
        _component.registerInternalEvents(ListViewEvents);
    }

    private override function createContentContainer(layoutName:String) {
        if (_contents == null) {
            super.createContentContainer(layoutName);
//            _contents.percentWidth = 100;   //TODO - would be nice to remove this. Defined in the css, but it doesn't work.
//            _contents.percentHeight = 100;   //TODO - would be nice to remove this. Defined in the css, but it doesn't work.
            _contents.addClass("listview-contents");
        }
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************

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

private class SelectedIndexBehaviour extends DataBehaviour {
    private var _currentSelection:ItemRenderer;

    private override function validateData() {
        var listView:ListView2 = cast(_component, ListView2);
        var selectedItem:ItemRenderer = cast listView.selectedItem;
        if(_currentSelection != selectedItem)
        {
            if (_currentSelection != null) {
                _currentSelection.removeClass(":selected", true, true);
            }

            _currentSelection = selectedItem;

            if (_currentSelection != null) {
                _currentSelection.addClass(":selected", true, true);
                _component.dispatch(new UIEvent(UIEvent.CHANGE));
            }
        }
    }
}

private class SelectedItemBehaviour extends Behaviour {
    public override function get():Variant {
        var listView:ListView2 = cast(_component, ListView2);
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        if (contents != null && listView.selectedIndex != -1 && listView.selectedIndex < contents.childComponents.length) {
            return cast(contents.childComponents[listView.selectedIndex], ItemRenderer);
        } else {
            return null;
        }
    }

    public override function set(value:Variant) {
        var listView:ListView2 = cast(_component, ListView2);
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        if (listView.dataSource != null && contents != null) {
            listView.selectedIndex = contents.childComponents.indexOf(value);
        }
    }
}