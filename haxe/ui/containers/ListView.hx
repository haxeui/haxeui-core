package haxe.ui.containers;

import haxe.ui.Toolkit;
import haxe.ui.actions.ActionType;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.behaviours.LayoutBehaviour;
import haxe.ui.components.Label;
import haxe.ui.components.VerticalScroll;
import haxe.ui.constants.SelectionMode;
import haxe.ui.containers.ScrollView.ScrollViewBuilder;
import haxe.ui.containers.ScrollView.ScrollViewEvents;
import haxe.ui.core.Component;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.data.DataSource;
import haxe.ui.events.ActionEvent;
import haxe.ui.events.ItemEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.ScrollEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.layouts.VerticalVirtualLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.MathUtil;
import haxe.ui.util.Variant;

@:composite(ListViewEvents, ListViewBuilder, VerticalVirtualLayout)
class ListView extends ScrollView implements IDataComponent implements IVirtualContainer {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(DataSourceBehaviour)                             public var dataSource:DataSource<Dynamic>;
    @:clonable @:behaviour(LayoutBehaviour, -1)                             public var itemWidth:Float;
    @:clonable @:behaviour(LayoutBehaviour, -1)                             public var itemHeight:Float;
    @:clonable @:behaviour(LayoutBehaviour, -1)                             public var itemCount:Int;
    @:clonable @:behaviour(LayoutBehaviour, false)                          public var variableItemSize:Bool;
    @:clonable @:behaviour(SelectedIndexBehaviour, -1)                      public var selectedIndex:Int;
    @:clonable @:behaviour(SelectedItemBehaviour)                           public var selectedItem:Dynamic;
    @:clonable @:behaviour(SelectedIndicesBehaviour)                        public var selectedIndices:Array<Int>;
    @:clonable @:behaviour(SelectedItemsBehaviour)                          public var selectedItems:Array<Dynamic>;
    @:clonable @:behaviour(SelectionModeBehaviour, SelectionMode.ONE_ITEM)  public var selectionMode:SelectionMode;
    @:clonable @:behaviour(DefaultBehaviour, 500)                           public var longPressSelectionTime:Int;  //ms
    @:clonable @:value(selectedIndex)                                       public var value:Dynamic;

    @:event(ItemEvent.COMPONENT_EVENT)                                      public var onComponentEvent:ItemEvent->Void;

    private var _itemRendererClass:Class<ItemRenderer>;
    @:clonable public var itemRendererClass(get, set):Class<ItemRenderer>;
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
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class ListViewEvents extends ScrollViewEvents {
    private var _listview:ListView;
    public var lastEvent:UIEvent;
    
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

    private function onScrollChange(e:ScrollEvent) {
        if (_listview.virtual == true) {
            _listview.invalidateComponentLayout();
        }
    }

    private function onRendererCreated(e:UIEvent) {
        var instance:ItemRenderer = cast(e.data, ItemRenderer);
        instance.registerEvent(MouseEvent.MOUSE_DOWN, onRendererMouseDown);
        instance.registerEvent(MouseEvent.CLICK, onRendererClick);
        instance.registerEvent(MouseEvent.RIGHT_CLICK, onRendererClick);
        if (_listview.selectedIndices.indexOf(instance.itemIndex) != -1) {
            var builder:ListViewBuilder = cast(_listview._compositeBuilder, ListViewBuilder);
            builder.addItemRendererClass(instance, ":selected");
        }
    }

    private function onRendererDestroyed(e:UIEvent) {
        var instance:ItemRenderer = cast(e.data, ItemRenderer);
        instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onRendererMouseDown);
        instance.unregisterEvent(MouseEvent.CLICK, onRendererClick);
        instance.unregisterEvent(MouseEvent.RIGHT_CLICK, onRendererClick);
        if (_listview.selectedIndices.indexOf(instance.itemIndex) != -1) {
            var builder:ListViewBuilder = cast(_listview._compositeBuilder, ListViewBuilder);
            builder.addItemRendererClass(instance, ":selected", false);
        }
    }

    private function onRendererMouseDown(e:MouseEvent) {
        _listview.focus = true;
        switch (_listview.selectionMode) {
            case SelectionMode.MULTIPLE_LONG_PRESS:
                if (_listview.selectedIndices.length == 0) {
                    startLongPressSelection(e);
                }

            default:
                if (_listview.hasClass(":mobile") == false) {
                    e.target.addClass(":hover");
                }
        }
    }

    private function startLongPressSelection(e:MouseEvent) {
        var timerClick:Timer = null;
        var currentMouseX:Float = e.screenX;
        var currentMouseY:Float = e.screenY;
        var renderer:ItemRenderer = cast(e.target, ItemRenderer);
        var __onMouseMove:MouseEvent->Void = null;
        var __onMouseUp:MouseEvent->Void = null;
        var __onMouseClick:MouseEvent->Void = null;

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

    private function onRendererClick(e:MouseEvent) {
        if (_containerEventsPaused == true) {
            return;
        }

        var components = e.target.findComponentsUnderPoint(e.screenX, e.screenY);
        for (component in components) {
            if (component != e.target && (component is InteractiveComponent) && cast(component, InteractiveComponent).allowInteraction == true) {
                return;
            }
        }
        
        lastEvent = e;
        
        var renderer:ItemRenderer = cast(e.target, ItemRenderer);
        switch (_listview.selectionMode) {
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
                    var fromIndex:Int = selectedIndices.length > 0 ? selectedIndices[selectedIndices.length - 1]: 0;
                    var toIndex:Int = renderer.itemIndex;
                    if (fromIndex < toIndex) {
                        for (i in selectedIndices) {
                            if (i < fromIndex) {
                                fromIndex = i;
                            }
                        }
                    } else {
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
        _listview.selectedIndices = [for (i in fromIndex...toIndex + 1) i];
    }
    
    private override function onActionStart(event:ActionEvent) {
        lastEvent = event;
        switch (event.action) {
            case ActionType.DOWN:
                if (_listview.selectedIndex < 0) {
                    _listview.selectedIndex = 0;
                } else {
                    var n:Int = _listview.selectedIndex;
                    n++;
                    if (n > _listview.dataSource.size - 1) {
                        n = 0;
                    }
                    _listview.selectedIndex = n;
                }
                event.repeater = true;
            case ActionType.UP:
                if (_listview.selectedIndex < 0) {
                    _listview.selectedIndex = _listview.dataSource.size - 1;
                } else {
                    var n:Int = _listview.selectedIndex;
                    n--;
                    if (n < 0) {
                        n = _listview.selectedIndex = _listview.dataSource.size - 1;
                    }
                    _listview.selectedIndex = n;
                }
                event.repeater = true;
            case _:    
        }
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
        if ((child is ItemRenderer) && (_listview.itemRenderer == null && _listview.itemRendererClass == null)) {
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
            if ((c is ItemRenderer)) {
                if (add == true) {
                    c.addClass(className);
                    Toolkit.callLater(function() {
                        ensureVisible(cast(c, ItemRenderer));
                    });
                } else {
                    c.removeClass(className);
                }
            } else {
                c.invalidateComponentStyle(); // we do want to invalidate the other components incase the css rule applies indirectly
            }
            return true;
        });
    }

    private function ensureVisible(itemToEnsure:ItemRenderer) {
        if (itemToEnsure != null && _listview.virtual == false) {
            var vscroll:VerticalScroll = _listview.findComponent(VerticalScroll);
            if (vscroll != null) {
                var vpos:Float = vscroll.pos;
                var contents:Component = _listview.findComponent("listview-contents", "css");
                if (itemToEnsure.top + itemToEnsure.height > vpos + contents.componentClipRect.height) {
                    vscroll.pos = ((itemToEnsure.top + itemToEnsure.height) - contents.componentClipRect.height);
                } else if (itemToEnsure.top < vpos) {
                    vscroll.pos = itemToEnsure.top;
                }
            }
        }
    }
    
    @:access(haxe.ui.layouts.VerticalVirtualLayout)
    private function ensureVirtualItemVisible(index:Int) {
        var vscroll:VerticalScroll = _listview.findComponent(VerticalScroll);
        if (vscroll != null) {
            var layout = cast(_listview.layout, VerticalVirtualLayout);
            var itemHeight = layout.itemHeight;
            var itemTop = index * itemHeight;
                var vpos:Float = vscroll.pos;
                var contents:Component = _listview.findComponent("listview-contents", "css");
                if (itemTop + itemHeight > vpos + contents.componentClipRect.height) {
                    vscroll.pos = ((itemTop + itemHeight) - contents.componentClipRect.height);
                } else if (itemTop < vpos) {
                    vscroll.pos = itemTop;
                }
        }
    }
    
    public override function applyStyle(style:Style) {
        super.applyStyle(style);
        haxe.ui.macros.ComponentMacros.cascacdeStylesToList(Label, [color, fontName, fontSize, cursor, textAlign]);
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
            dataSource.onDataSourceChange = function() {
                _component.invalidateComponentLayout();
                if (_firstPass == true) {
                    //_component.syncComponentValidation();
                    _firstPass = false;
                    _component.invalidateComponentLayout();
                }
                dispatchChanged();
            }
            
            _component.invalidateComponentLayout();
        } else {
            _component.invalidateComponentLayout();
        }
        dispatchChanged();
    }

    public override function get():Variant {
        if (_value == null || _value.isNull) {
            _value = new ArrayDataSource<Dynamic>();
            set(_value);
        }
        return _value;
    }
    
    private function dispatchChanged() {
        Toolkit.callLater(function() {
            _component.dispatch(new UIEvent(UIEvent.PROPERTY_CHANGE, false, "dataSource"));
        });
    }
}

@:dox(hide) @:noCompletion
private class SelectedIndexBehaviour extends Behaviour {
    public override function get():Variant {
        var listView:ListView = cast(_component, ListView);
        var selectedIndices:Array<Int> = listView.selectedIndices;
        return selectedIndices != null && selectedIndices.length > 0 ? selectedIndices[selectedIndices.length - 1] : -1;
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
        var builder:ListViewBuilder = cast(_component._compositeBuilder, ListViewBuilder);
        var events:ListViewEvents = cast(_component._internalEvents, ListViewEvents);

        for (child in contents.childComponents) {
            if (selectedIndices.indexOf(cast(child, ItemRenderer).itemIndex) != -1) {
                builder.addItemRendererClass(child, ":selected");
            } else {
                builder.addItemRendererClass(child, ":selected", false);
            }
        }

        if (listView.virtual == true) {
            for (i in selectedIndices) {
                @:privateAccess builder.ensureVirtualItemVisible(i);
            }
        }
        
        if (listView.selectedIndex != -1 && listView.selectedIndices.length != 0) {
            var event = new UIEvent(UIEvent.CHANGE);
            event.relatedEvent = events.lastEvent;
            _component.dispatch(event);
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
        if (selectedIndices == null || selectedIndices.length == 0) {
            return;
        }

        var selectionMode:SelectionMode = _value.toString();
        switch (selectionMode) {
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