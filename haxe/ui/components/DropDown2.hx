package haxe.ui.components;

import haxe.ui.components.Button.ButtonEvents;
import haxe.ui.containers.CalendarView;
import haxe.ui.containers.ListView2;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.DefaultBehaviour;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.Screen;
import haxe.ui.core.UIEvent;
import haxe.ui.data.DataSource;

@:composite(DropDownEvents, DropDownBuilder)
class DropDown2 extends Button implements IDataComponent {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(DefaultBehaviour)                    public var dataSource:DataSource<Dynamic>;
    @:behaviour(DefaultBehaviour, "list")            public var type:String;
    @:behaviour(DefaultBehaviour, false)             public var virtual:Bool;
    @:behaviour(DefaultBehaviour)                    public var dropDownWidth:Null<Float>;
}

//***********************************************************************************************************
// Dropdown Handlers
//***********************************************************************************************************
interface IDropDownHandler {
    var component(get, null):Component;
    function show():Void;
}

class DropDownHandler implements IDropDownHandler {
    private var _dropdown:DropDown2;
    
    public function new(dropdown:DropDown2) {
        _dropdown = dropdown;
    }

    public var component(get, null):Component;
    private function get_component():Component {
        return null;
    }
    
    public function show() {
    }
}

@:access(haxe.ui.core.Component)
class ListDropDownHandler extends DropDownHandler {
    private var _listview:ListView2;
    
    private override function get_component():Component {
        return _listview;
    }
    
    public override function show() {
        if (_listview == null) {
            _listview = new ListView2();
            _listview.virtual = _dropdown.virtual;
            _listview.dataSource = _dropdown.dataSource;
            _listview.registerEvent(UIEvent.CHANGE, onListChange);
        }

        var itemCount = 4; //TODO - the user could customize it
        if (_listview.dataSource.size < itemCount) {
            itemCount = _listview.dataSource.size;
        }
        _listview.itemCount = itemCount; 
        if (_dropdown.dropDownWidth == null) {
            _listview.width = _dropdown.width;
        } else {
            _listview.width = _dropdown.dropDownWidth;
        }

        Screen.instance.addComponent(_listview);
    }
    
    private function onListChange(event:UIEvent) {
        if (_listview.selectedItem == null) {
            return;
        }
        var currentHover = _listview.findComponent(":hover", null, true, "css");
        if (currentHover != null) { // since the dropdown list dissapears it does recvieve a mouse out (sometimes)
            currentHover.removeClass(":hover");
        }
        var text = _listview.selectedItem.value;
        _dropdown.text = text;
        cast(_dropdown._internalEvents, DropDownEvents).hideDropDown();
    }
}

@:access(haxe.ui.core.Component)
class CalendarDropDownHandler extends DropDownHandler {
    private var _calendar:CalendarView;
    
    private override function get_component():Component {
        return _calendar;
    }
    
    public override function show() {
        if (_calendar == null) {
            _calendar = new CalendarView();
            _calendar.registerEvent(UIEvent.CHANGE, onCalendarChange);
        }    
        
        if (_dropdown.dropDownWidth != null) {
            _calendar.width = _dropdown.dropDownWidth;
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
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class DropDownEvents extends ButtonEvents {
    private var _dropdown:DropDown2;
    private var _handler:IDropDownHandler;
    
    public function new(dropdown:DropDown2) {
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
        if (_handler == null) {
            var handlerClass:String = DropDownBuilder.HANDLER_MAP.get(_dropdown.type);
            if (handlerClass == null) {
                handlerClass = _dropdown.type;
            }
            _handler = Type.createInstance(Type.resolveClass(handlerClass), [_dropdown]);
        }
        
        _handler.show();
        _handler.component.addClass("popup");
        _handler.component.left = _dropdown.screenLeft;
        _handler.component.top = _dropdown.screenTop + _dropdown.height - 1;
        
        if (_handler.component.screenTop + _handler.component.height > Screen.instance.height) {
            _handler.component.top = _dropdown.screenTop - _handler.component.height;
        }
        
        Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
    }
    
    public function hideDropDown() {
        if (_handler == null) {
            return;
        }
        
        _dropdown.selected = false;
        Screen.instance.removeComponent(_handler.component);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
        
    }
    
    private function onScreenMouseDown(event:MouseEvent) {
        if (_handler.component.hitTest(event.screenX, event.screenY) == true) {
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
private class DropDownBuilder extends CompositeBuilder {
    public static var HANDLER_MAP:Map<String, String> = new Map<String, String>();
    
    private var _dropdown:DropDown2;

    public function new(dropdown:DropDown2) {
        super(dropdown);
        _dropdown = dropdown;
        
        HANDLER_MAP.set("list", Type.getClassName(ListDropDownHandler));
        HANDLER_MAP.set("date", Type.getClassName(CalendarDropDownHandler));
    }
    
    public override function create() {
        _dropdown.toggle = true;
    }
    
    public override function destroy() {
        var events:DropDownEvents = cast(_dropdown._internalEvents, DropDownEvents);
        events.hideDropDown();
        if (events._handler != null && events._handler.component != null) {
            events._handler.component.destroyComponent();
        }
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
