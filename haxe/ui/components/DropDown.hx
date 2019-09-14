package haxe.ui.components;

import haxe.ui.components.Button.ButtonBuilder;
import haxe.ui.components.Button.ButtonEvents;
import haxe.ui.containers.CalendarView;
import haxe.ui.containers.ListView;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.core.IDataComponent;
import haxe.ui.events.MouseEvent;
import haxe.ui.core.Screen;
import haxe.ui.events.UIEvent;
import haxe.ui.data.DataSource;
import haxe.ui.util.Variant;

@:composite(DropDownEvents, DropDownBuilder)
class DropDown extends Button implements IDataComponent {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(DefaultBehaviour)                    public var handlerStyleNames:String;
    @:behaviour(DataSourceBehaviour)                 public var dataSource:DataSource<Dynamic>;
    @:behaviour(DefaultBehaviour, "list")            public var type:String;
    @:behaviour(DefaultBehaviour, false)             public var virtual:Bool;
    @:behaviour(DefaultBehaviour)                    public var dropdownWidth:Null<Float>;
    @:behaviour(DefaultBehaviour)                    public var dropdownHeight:Null<Float>;
    @:behaviour(DefaultBehaviour)                    public var dropdownSize:Null<Int>;
    @:behaviour(SelectedIndexBehaviour, -1)          public var selectedIndex:Int;
    @:behaviour(SelectedItemBehaviour)               public var selectedItem:Dynamic;
}

//***********************************************************************************************************
// Composite Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class DataSourceBehaviour extends DefaultBehaviour {
    public override function set(value:Variant) {
        super.set(value);
        if (value == _value) {
            return;
        }
        
        var handler:IDropDownHandler = cast(_component._compositeBuilder, DropDownBuilder).handler;
        handler.reset();
        if (_component.text == null) {
            cast(_component, DropDown).selectedIndex = 0;
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class SelectedIndexBehaviour extends DataBehaviour {
    private override function validateData() {
        var handler:IDropDownHandler = cast(_component._compositeBuilder, DropDownBuilder).handler;
        handler.selectedIndex = _value;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class SelectedItemBehaviour extends Behaviour {
    public override function getDynamic():Dynamic {
        var handler:IDropDownHandler = cast(_component._compositeBuilder, DropDownBuilder).handler;
        return handler.selectedItem;
    }
}

//***********************************************************************************************************
// Dropdown Handlers
//***********************************************************************************************************
interface IDropDownHandler {
    var component(get, null):Component;
    function show():Void;
    function reset():Void;
    var selectedIndex(get, set):Int;
    var selectedItem(get, null):Dynamic;
    
}

class DropDownHandler implements IDropDownHandler {
    private var _dropdown:DropDown;
    
    public function new(dropdown:DropDown) {
        _dropdown = dropdown;
    }

    public var component(get, null):Component;
    private function get_component():Component {
        return null;
    }
    
    public function show() {
    }
    
    public function reset() {
    }
    
    public var selectedIndex(get, set):Int;
    private function get_selectedIndex():Int {
        return -1;
    }
    private function set_selectedIndex(value:Int):Int {
        return value;
    }
    
    public var selectedItem(get, null):Dynamic;
    private function get_selectedItem():Dynamic {
        return null;
    }
}

@:access(haxe.ui.core.Component)
class ListDropDownHandler extends DropDownHandler {
    private var _listview:ListView;
    
    private override function get_component():Component {
        createListView();
        return _listview;
    }
    
    public override function reset() {
        _cachedSelectedIndex = -1;
        if (_listview != null) {
            _listview.unregisterEvent(UIEvent.CHANGE, onListChange);
        }
        _listview = null;
        createListView();
        //_dropdown.selectedIndex = -1;
    }
    
    public override function show() {
        var itemCount = 4;
        if (_dropdown.dropdownSize != null) {
            itemCount = _dropdown.dropdownSize;
        }
        if (_listview.dataSource != null && _listview.dataSource.size < itemCount) {
            itemCount = _listview.dataSource.size;
        }

        _listview.itemCount = itemCount; 
        if (_dropdown.dropdownWidth == null) {
            _listview.width = _dropdown.width;
        } else {
            _listview.width = _dropdown.dropdownWidth;
        }
        if (_dropdown.dropdownHeight != null) {
            _listview.height = _dropdown.dropdownHeight;
        }

        var selectedIndex = _dropdown.selectedIndex;
        if (_dropdown.dataSource != null && _dropdown.text != null && selectedIndex < 0) {
            var text = _dropdown.text;
            for (i in 0..._dropdown.dataSource.size) {
                var item:Dynamic = _dropdown.dataSource.get(i);
                if (item == text || item.value == text || item.text == text) {
                    selectedIndex = i;
                }
            }
        }
        
        Screen.instance.addComponent(_listview);
        _listview.unregisterEvent(UIEvent.CHANGE, onListChange); // TODO: not great!
        _listview.selectedIndex = selectedIndex;
        _listview.syncComponentValidation();
        _listview.registerEvent(UIEvent.CHANGE, onListChange); // TODO: not great!
    }
    
    private var _cachedSelectedIndex:Int = -1;
    private override function get_selectedIndex():Int{
        if (_listview == null) {
            return _cachedSelectedIndex;
        }
        return _listview.selectedIndex;
    }
    
    private override function set_selectedIndex(value:Int):Int {
        if (_listview != null) {
            _listview.selectedIndex = value;
            _cachedSelectedIndex = value;
        } else if (_cachedSelectedIndex != value) {
            _cachedSelectedIndex = value;
            _dropdown.dispatch(new UIEvent(UIEvent.CHANGE));
        }
        
        if (value >= 0 && value < _dropdown.dataSource.size) {
            var data = _dropdown.dataSource.get(value);
            _dropdown.text = data.value;
        }
        
        return value;
    }
    
    private override function get_selectedItem():Dynamic {
        if (_listview == null) {
            if (_cachedSelectedIndex >= 0 && _cachedSelectedIndex < _dropdown.dataSource.size) {
                var data = _dropdown.dataSource.get(_cachedSelectedIndex);
                return data;
            } else {
                return null;
            }
        }
        return _listview.selectedItem;
    }
    
    
    private function createListView() {
        if (_listview == null) {
            _listview = new ListView();
            _listview.virtual = _dropdown.virtual;
            _listview.dataSource = _dropdown.dataSource;
        }
    }
    
    private function onListChange(event:UIEvent) {
        if (_listview.selectedItem == null) {
            return;
        }
        var currentHover:Component = _listview.findComponent(":hover", null, true, "css");
        if (currentHover != null) { // since the dropdown list dissapears it doesnt recvieve a mouse out (sometimes)
            currentHover.removeClass(":hover");
        }
        var text = _listview.selectedItem.value;
        _dropdown.text = text;
        _dropdown.selectedIndex = _listview.selectedIndex;
        cast(_dropdown._internalEvents, DropDownEvents).hideDropDown();
        _dropdown.dispatch(new UIEvent(UIEvent.CHANGE));
    }
}

@:access(haxe.ui.core.Component)
class CalendarDropDownHandler extends DropDownHandler {
    private var _calendar:CalendarView;
    
    private override function get_component():Component {
        if (_calendar == null) {
            _calendar = new CalendarView();
            _calendar.registerEvent(UIEvent.CHANGE, onCalendarChange);
        }    
        return _calendar;
    }
    
    public override function show() {
        if (_dropdown.dropdownWidth != null) {
            _calendar.width = _dropdown.dropdownWidth;
        }
        if (_dropdown.dropdownHeight != null) {
            _calendar.height = _dropdown.dropdownHeight;
        }
        
        Screen.instance.addComponent(_calendar);
        _calendar.syncComponentValidation();
    }
    
    public function onCalendarChange(event:UIEvent) {
        if (_calendar.selectedDate == null) {
            return;
        }
        _dropdown.text = DateTools.format(_calendar.selectedDate, CalendarView.DATE_FORMAT);
        cast(_dropdown._internalEvents, DropDownEvents).hideDropDown();
        _dropdown.dispatch(new UIEvent(UIEvent.CHANGE));
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class DropDownEvents extends ButtonEvents {
    private var _dropdown:DropDown;
    
    public function new(dropdown:DropDown) {
        super(dropdown);
        _dropdown = dropdown;
    }
    
    public override function register() {
        super.register();
        registerEvent(MouseEvent.CLICK, onClick);
    }
    
    public override function unregister() {
        super.unregister();
        unregisterEvent(MouseEvent.CLICK, onClick);
    }
    
    private function onClick(event:MouseEvent) {
        if (_dropdown.selected == true) {
            showDropDown();
        } else {
            hideDropDown();
        }
    }
    
    private var _overlay:Component = null;
    @:access(haxe.ui.core.Component)
    public function showDropDown() {
        var handler:IDropDownHandler = cast(_dropdown._compositeBuilder, DropDownBuilder).handler;
        handler.component.addClass("popup");
        handler.component.addClass("dropdown-popup");
        handler.component.styleNames = _dropdown.handlerStyleNames;
        var componentOffset = _dropdown.getComponentOffset();
        
        var mode = "mobile";
        if (_dropdown.style.mode != null && _dropdown.style.mode == "mobile") {
            if (_overlay == null) {
                _overlay = new Component();
                _overlay.id = "modal-background";
                _overlay.addClass("modal-background");
                _overlay.percentWidth = _overlay.percentHeight = 100;
            }
            Screen.instance.addComponent(_overlay);
            
            handler.show();
            handler.component.left = (Screen.instance.width / 2) - (handler.component.actualComponentWidth / 2);
            handler.component.top = (Screen.instance.height / 2) - (handler.component.actualComponentHeight / 2);
        } else {
            handler.component.left = _dropdown.screenLeft + componentOffset.x;
            handler.component.top = _dropdown.screenTop + (_dropdown.actualComponentHeight - Toolkit.scaleY) + componentOffset.y;
            handler.show();

            if (handler.component.screenLeft + handler.component.width > Screen.instance.width) {
                handler.component.left = handler.component.screenLeft - handler.component.width + _dropdown.width;
            }
            if (handler.component.screenTop + handler.component.height > Screen.instance.height) {
                handler.component.top = _dropdown.screenTop - handler.component.height;
            }
        }

        Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
        Screen.instance.registerEvent(MouseEvent.RIGHT_MOUSE_DOWN, onScreenMouseDown);
    }
    
    public function hideDropDown() {
        var handler:IDropDownHandler = cast(_dropdown._compositeBuilder, DropDownBuilder).handler;
        if (handler == null) {
            return;
        }
        
        if (_overlay != null) {
            Screen.instance.removeComponent(_overlay);
            _overlay = null;
        }
        
        _dropdown.selected = false;
        Screen.instance.removeComponent(handler.component);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
        Screen.instance.unregisterEvent(MouseEvent.RIGHT_MOUSE_DOWN, onScreenMouseDown);
    }
    
    @:access(haxe.ui.core.Component)
    private function onScreenMouseDown(event:MouseEvent) {
        var handler:IDropDownHandler = cast(_dropdown._compositeBuilder, DropDownBuilder).handler;
        if (handler.component.hitTest(event.screenX, event.screenY) == true) {
            return;
        }
        var componentOffset = _dropdown.getComponentOffset();
        if (_dropdown.hitTest(event.screenX - componentOffset.x, event.screenY - componentOffset.y) == true) {
            return;
        }
        
        hideDropDown();
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.components.DropDownEvents)
private class DropDownBuilder extends ButtonBuilder {
    
    public static var HANDLER_MAP:Map<String, String> = new Map<String, String>();
    
    private var _dropdown:DropDown;
    @:noCompletion private var _handler:IDropDownHandler;

    public function new(dropdown:DropDown) {
        super(dropdown);
        _dropdown = dropdown;
        
        HANDLER_MAP.set("list", Type.getClassName(ListDropDownHandler));
        HANDLER_MAP.set("date", Type.getClassName(CalendarDropDownHandler));
    }
    
    public var handler(get, null):IDropDownHandler;
    private function get_handler():IDropDownHandler {
        if (_handler == null) {
            var handlerClass:String = DropDownBuilder.HANDLER_MAP.get(_dropdown.type);
            if (handlerClass == null) {
                handlerClass = _dropdown.type;
            }
            _handler = Type.createInstance(Type.resolveClass(handlerClass), [_dropdown]);
        }
        
        return _handler;
    }
    
    public override function create() {
        _dropdown.toggle = true;
        if (_dropdown.text == null) {
            _dropdown.selectedIndex = 0;
        }
    }
    
    public override function destroy() {
        var events:DropDownEvents = cast(_dropdown._internalEvents, DropDownEvents);
        events.hideDropDown();
        if (_handler != null && _handler.component != null) {
            _handler.component.destroyComponent();
        }
    }
}
