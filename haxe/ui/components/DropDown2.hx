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
    
    private var _first:Bool = true;
    public override function show() {
        if (_listview == null) {
            _listview = new ListView2();
            _listview.addClass("popup");
            _listview.dataSource = _dropdown.dataSource;
            _listview.registerEvent(UIEvent.CHANGE, onListChange);
        }

        Screen.instance.addComponent(_listview);
        if (_first == true) {
            _listview.syncComponentValidation(); // need this so we can get correct padding value
            _first = false;
        }
        
        _listview.width = _dropdown.width;
        _listview.height = (calcItemHeight() * listSize()) + _listview.style.paddingTop + _listview.style.paddingBottom;
    }
    
    private function onListChange(event:UIEvent) {
        if (_listview.selectedItem == null) {
            return;
        }
        var text = _listview.selectedItem.value;
        _dropdown.text = text;
        cast(_dropdown._internalEvents, DropDownEvents).hideDropDown();
    }
    
    private function calcItemHeight():Float {
        var contents:Component = _listview.findComponent("listview-contents", false, "css");
        var items = contents.childComponents;
        var size = listSize();
        var total:Float = 0;
        for (n in 0...size) {
            total += items[n].height;
        }
        return total / size; // might be a nicer way to do this
    }
    
    private function listSize():Int {  // TODO: get from dropdown, not sure about prop name... "listsize" doesnt make sense as might not always be a list (ie, colour selector, data selector, etc)
        var n = 4;
        var contents:Component = _listview.findComponent("listview-contents", false, "css");
        if (n > contents.childComponents.length) {
            n = contents.childComponents.length;
        }
        return n;
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
            _calendar.addClass("popup");
            
            _calendar.registerEvent(UIEvent.CHANGE, onCalendarChange);
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
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
