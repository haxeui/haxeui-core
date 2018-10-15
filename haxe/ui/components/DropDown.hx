package haxe.ui.components;

import haxe.ui.components.Button.ButtonBuilder;
import haxe.ui.components.Button.ButtonEvents;
import haxe.ui.containers.CalendarView;
import haxe.ui.containers.ListView2;
import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.DataBehaviour;
import haxe.ui.core.DefaultBehaviour;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.Screen;
import haxe.ui.core.UIEvent;
import haxe.ui.data.DataSource;
import haxe.ui.util.Variant;

@:composite(DropDownEvents, DropDownBuilder)
class DropDown extends Button implements IDataComponent {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(DefaultBehaviour)                    public var dataSource:DataSource<Dynamic>;
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
private class SelectedIndexBehaviour extends DataBehaviour {
    private override function validateData() {
        var handler:IDropDownHandler = cast(_component._compositeBuilder, DropDownBuilder).handler;
        handler.selectedIndex = _value;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class SelectedItemBehaviour extends Behaviour {
    public override function get():Variant {
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
    private var _listview:ListView2;
    
    private override function get_component():Component {
        createListView();
        return _listview;
    }
    
    public override function show() {
        var itemCount = 4; //TODO - the user could customize it
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

        Screen.instance.addComponent(_listview);
        _listview.unregisterEvent(UIEvent.CHANGE, onListChange); // TODO: not great!
        _listview.selectedIndex = _dropdown.selectedIndex;
        _listview.syncComponentValidation();
        _listview.registerEvent(UIEvent.CHANGE, onListChange); // TODO: not great!
    }
    
    private override function get_selectedIndex():Int{
        if (_listview == null) {
            return -1;
        }
        return _listview.selectedIndex;
    }
    
    private override function set_selectedIndex(value:Int):Int {
        if (_listview != null) {
            _listview.selectedIndex = value;
        }
        var data = _dropdown.dataSource.get(value);
        _dropdown.text = data.value;
        return value;
    }
    
    private override function get_selectedItem():Dynamic {
        return _listview.selectedItem;
    }
    
    
    private function createListView() {
        if (_listview == null) {
            _listview = new ListView2();
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
    }
    
    public function onCalendarChange(event:UIEvent) {
        if (_calendar.selectedDate == null) {
            return;
        }
        var dateFormat:String = "%d/%m/%Y";
        _dropdown.text = DateTools.format(_calendar.selectedDate, dateFormat);
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
    
    public function showDropDown() {
        var handler:IDropDownHandler = cast(_dropdown._compositeBuilder, DropDownBuilder).handler;
        handler.component.addClass("popup");
        handler.component.left = _dropdown.screenLeft;
        handler.component.top = _dropdown.screenTop + _dropdown.height - 1;
        handler.show();

        if (handler.component.screenLeft + handler.component.width > Screen.instance.width) {
            handler.component.left = handler.component.screenLeft - handler.component.width + _dropdown.width;
        }
        if (handler.component.screenTop + handler.component.height > Screen.instance.height) {
            handler.component.top = _dropdown.screenTop - handler.component.height;
        }
        
        Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
    }
    
    public function hideDropDown() {
        var handler:IDropDownHandler = cast(_dropdown._compositeBuilder, DropDownBuilder).handler;
        if (handler == null) {
            return;
        }
        
        _dropdown.selected = false;
        Screen.instance.removeComponent(handler.component);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
        
    }
    
    private function onScreenMouseDown(event:MouseEvent) {
        var handler:IDropDownHandler = cast(_dropdown._compositeBuilder, DropDownBuilder).handler;
        if (handler.component.hitTest(event.screenX, event.screenY) == true) {
            return;
        }
        if (_dropdown.hitTest(event.screenX, event.screenY) == true) {
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
    }
    
    public override function destroy() {
        var events:DropDownEvents = cast(_dropdown._internalEvents, DropDownEvents);
        events.hideDropDown();
        if (_handler != null && _handler.component != null) {
            _handler.component.destroyComponent();
        }
    }
}
