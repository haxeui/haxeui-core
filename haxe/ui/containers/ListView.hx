package haxe.ui.containers;

import haxe.ui.behaviours.Behaviour;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.behaviours.LayoutBehaviour;
import haxe.ui.binding.BindingManager;
import haxe.ui.components.VerticalScroll;
import haxe.ui.constants.SelectionMode;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.ScrollView.ScrollViewBuilder;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.data.DataSource;
import haxe.ui.data.transformation.NativeTypeTransformer;
import haxe.ui.events.ItemEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.ScrollEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.layouts.VerticalVirtualLayout;
import haxe.ui.util.MathUtil;
import haxe.ui.util.Variant;

@:composite(ListViewEvents, ListViewBuilder, VerticalVirtualLayout)
class ListView extends ScrollView implements IDataComponent implements IVirtualContainer {
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

    @:event(ItemEvent.COMPONENT_EVENT)                          public var onComponentEvent:ItemEvent->Void;
    
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

@:dox(hide) @:noCompletion
typedef ItemRendererFunction2 = Dynamic->Int->Class<ItemRenderer>;    //(data, index):Class<ItemRenderer>

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class ListViewEvents extends ScrollViewEvents {
    private var _listview:ListView;

    public function new(listview:ListView) {
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
        instance.registerEvent(MouseEvent.MOUSE_DOWN, onRendererMouseDown);
        instance.registerEvent(MouseEvent.CLICK, onRendererClick);
        if (_listview.selectedIndices.indexOf(instance.itemIndex) != -1) {
            var builder:ListViewBuilder = cast(_listview._compositeBuilder, ListViewBuilder);
            builder.addItemRendererClass(instance, ":selected");
        }
    }

    private function onRendererDestroyed(e:UIEvent) {
        var instance:ItemRenderer = cast(e.data, ItemRenderer);
        instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onRendererMouseDown);
        instance.unregisterEvent(MouseEvent.CLICK, onRendererClick);
        if (_listview.selectedIndices.indexOf(instance.itemIndex) != -1) {
            var builder:ListViewBuilder = cast(_listview._compositeBuilder, ListViewBuilder);
            builder.addItemRendererClass(instance, ":selected", false);
        }
    }

    private function onRendererMouseDown(e:MouseEvent) {
        switch(_listview.selectionMode) {
            case SelectionMode.MULTIPLE_LONG_PRESS:
                if (_listview.selectedIndices.length == 0) {
                    startLongPressSelection(e);
                }

            default:
                e.target.addClass(":hover");
        }
    }

    private function startLongPressSelection(e:MouseEvent) {
        var timerClick:Timer = null;
        var currentMouseX:Float = e.screenX, currentMouseY:Float = e.screenY;
        var renderer:ItemRenderer = cast(e.target, ItemRenderer);
        var __onMouseMove:MouseEvent->Void = null, __onMouseUp:MouseEvent->Void, __onMouseClick:MouseEvent->Void;

        __onMouseMove = function (_e:MouseEvent) {
            currentMouseX = _e.screenX;
            currentMouseY = _e.screenY;
        }

        __onMouseUp = function (_e:MouseEvent) {
            if (timerClick != null) {
                timerClick.stop();
                timerClick = null;
            }

            renderer.screen.unregisterEvent(MouseEvent.MOUSE_MOVE, __onMouseMove);
            renderer.screen.unregisterEvent(MouseEvent.MOUSE_UP, __onMouseUp);
        }

        __onMouseClick = function(_e:MouseEvent) {
            _e.cancel();    //Avoid toggleSelection onRendererClick method

            renderer.unregisterEvent(MouseEvent.CLICK, __onMouseClick);
        }

        renderer.screen.registerEvent(MouseEvent.MOUSE_MOVE, __onMouseMove);
        renderer.screen.registerEvent(MouseEvent.MOUSE_UP, __onMouseUp);

        timerClick = Timer.delay(function(){
            if (timerClick != null) {
                timerClick = null;

                if (renderer.hitTest(currentMouseX, currentMouseY) &&
                    MathUtil.distance(e.screenX, e.screenY, currentMouseX, currentMouseY) < 2 * Toolkit.pixelsPerRem) {
                    toggleSelection(renderer);
                    renderer.registerEvent(MouseEvent.CLICK, __onMouseClick, 1);
                }
            }
        }, _listview.longPressSelectionTime);
    }
    
    private override function onContainerEventsStatusChanged() {
        super.onContainerEventsStatusChanged();
        if (_containerEventsPaused == true) {
            _scrollview.findComponent("listview-contents", Component, true, "css").removeClass(":hover", true, true);
        } else if (_lastMousePos != null) {
            /* TODO: may be ill concieved, doesnt look good on mobile
            var items = _scrollview.findComponentsUnderPoint(_lastMousePos.x, _lastMousePos.y, ItemRenderer);
            for (i in items) {
                i.addClass(":hover", true, true);
            }
            */
        }
    }
    
    private function onRendererClick(e:MouseEvent):Void {
        if (_containerEventsPaused == true) {
            return;
        }
        
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

            case SelectionMode.MULTIPLE_MODIFIER_KEY, SelectionMode.MULTIPLE_CLICK_MODIFIER_KEY:
                if (e.ctrlKey == true) {
                    toggleSelection(renderer);
                } else if (e.shiftKey == true) {
                    var selectedIndices:Array<Int> = _listview.selectedIndices;
                    var fromIndex:Int = selectedIndices.length > 0 ? selectedIndices[selectedIndices.length-1]: 0;
                    var toIndex:Int = renderer.itemIndex;
                    if (fromIndex < toIndex)
                    {
                        for (i in selectedIndices) {
                            if (i < fromIndex) {
                                fromIndex = i;
                            }
                        }
                    }
                    else
                    {
                        var tmp:Int = fromIndex;
                        fromIndex = toIndex;
                        toIndex = tmp;
                    }

                    selectRange(fromIndex, toIndex);
                } else if (_listview.selectionMode == SelectionMode.MULTIPLE_CLICK_MODIFIER_KEY) {
                    _listview.selectedIndex = renderer.itemIndex;
                }

            case SelectionMode.MULTIPLE_LONG_PRESS:
                var selectedIndices:Array<Int> = _listview.selectedIndices;
                if (selectedIndices.length > 0) {
                    toggleSelection(renderer);
                }

            default:
                //Nothing
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

    private function selectRange(fromIndex:Int, toIndex:Int) {
        _listview.selectedIndices = [for (i in fromIndex...toIndex+1) i];
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class ListViewBuilder extends ScrollViewBuilder {
    private var _listview:ListView;

    public function new(listview:ListView) {
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
    
    @:access(haxe.ui.backend.ComponentImpl)
    public override function addComponent(child:Component):Component {
        var r = null;
        if (Std.is(child, ItemRenderer) && (_listview.itemRenderer == null && _listview.itemRendererFunction == null && _listview.itemRendererClass == null)) {
            _listview.itemRenderer = cast(child, ItemRenderer);
            _listview.itemRenderer.ready();
            _listview.itemRenderer.handleVisibility(false);
            r = child;
        } else {
            r = super.addComponent(child);
        }
        return r;
    }
    
    public override function onVirtualChanged() {
        _contents.layoutName = _listview.virtual ? "absolute" : "vertical";
    }
    
    public function addItemRendererClass(child:Component, className:String, add:Bool = true) {
        child.walkComponents(function(c) {
            if (Std.is(c, ItemRenderer)) {
                if (add == true) {
                    c.addClass(className);
                } else {
                    c.removeClass(className);
                }
            } else {
                c.invalidateComponentStyle(); // we do want to invalidate the other components incase the css rule applies indirectly
            }
            return true;
        });
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
    
    public override function get():Variant {
        if (_value == null || _value.isNull) {
            _value = new ArrayDataSource<Dynamic>();
            set(_value);
        }
        return _value;
    }
}

@:dox(hide) @:noCompletion
private class SelectedIndexBehaviour extends Behaviour {
    public override function get():Variant {
        var listView:ListView = cast(_component, ListView);
        var selectedIndices:Array<Int> = listView.selectedIndices;
        return selectedIndices != null && selectedIndices.length > 0 ? selectedIndices[selectedIndices.length-1] : -1;
    }

    public override function set(value:Variant) {
        var listView:ListView = cast(_component, ListView);
        listView.selectedIndices = value != -1 ? [value] : null;
    }
}

@:dox(hide) @:noCompletion
private class SelectedItemBehaviour extends Behaviour {
    public override function getDynamic():Dynamic {
        var listView:ListView = cast(_component, ListView);
        var selectedIndices:Array<Int> = listView.selectedIndices;
        return selectedIndices.length > 0 ? listView.dataSource.get(selectedIndices[selectedIndices.length - 1]) : null;
    }

    public override function set(value:Variant) {
        var listView:ListView = cast(_component, ListView);
        var index:Int = listView.dataSource.indexOf(value);
        if (index != -1 && listView.selectedIndices.indexOf(index) == -1) {
            listView.selectedIndices = [index];
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class SelectedIndicesBehaviour extends DataBehaviour {
    public override function get():Variant {
        return _value.isNull ? [] : _value;
    }

    private override function validateData() {
        var listView:ListView = cast(_component, ListView);
        var selectedIndices:Array<Int> = listView.selectedIndices;
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        var itemToEnsure:ItemRenderer = null;
        var builder:ListViewBuilder = cast(_component._compositeBuilder, ListViewBuilder);
        
        for (child in contents.childComponents) {
            if (selectedIndices.indexOf(cast(child, ItemRenderer).itemIndex) != -1) {
                itemToEnsure = cast(child, ItemRenderer);
                builder.addItemRendererClass(child, ":selected");
            } else {
                builder.addItemRendererClass(child, ":selected", false);
            }
        }

        if (itemToEnsure != null && listView.virtual == false) { // TODO: virtual scroll into view
            var vscroll:VerticalScroll = listView.findComponent(VerticalScroll);
            if (vscroll != null) {
                var vpos:Float = vscroll.pos;
                var contents:Component = listView.findComponent("listview-contents", "css");
                if (itemToEnsure.top + itemToEnsure.height > vpos + contents.componentClipRect.height) {
                    vscroll.pos = ((itemToEnsure.top + itemToEnsure.height) - contents.componentClipRect.height);
                } else if (itemToEnsure.top < vpos) {
                    vscroll.pos = itemToEnsure.top;
                }
            }
        }
        
        if (listView.selectedIndex != -1 && listView.selectedIndices.length != 0) {
            _component.dispatch(new UIEvent(UIEvent.CHANGE));
        }
    }
}

@:dox(hide) @:noCompletion
private class SelectedItemsBehaviour extends Behaviour {
    public override function get():Variant {
        var listView:ListView = cast(_component, ListView);
        var selectedIndices:Array<Int> = listView.selectedIndices;
        if (selectedIndices != null && selectedIndices.length > 0) {
            var selectedItems:Array<Dynamic> = [];
            for (i in selectedIndices) {
                if ((i < 0) || (i >= listView.dataSource.size)) {
                    continue;
                }
                var data:Dynamic = listView.dataSource.get(i);
                selectedItems.push(data);
            }

            return selectedItems;
        } else {
            return [];
        }
    }

    public override function set(value:Variant) {
        var listView:ListView = cast(_component, ListView);
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
        var listView:ListView = cast(_component, ListView);
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