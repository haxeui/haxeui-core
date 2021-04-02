package haxe.ui.components;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.binding.BindingManager;
import haxe.ui.components.Button.ButtonBuilder;
import haxe.ui.components.Button.ButtonEvents;
import haxe.ui.containers.Box;
import haxe.ui.containers.CalendarView;
import haxe.ui.containers.ListView;
import haxe.ui.core.Component;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.Screen;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.data.DataSource;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
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
    @:call(HideDropDown)                             public function hideDropDown();
    @:clonable @:value(selectedItem)                 public var value:Dynamic;

    private override function onThemeChanged() {
        super.onThemeChanged();
        var builder:DropDownBuilder = cast(this._compositeBuilder, DropDownBuilder);
        builder.onThemeChanged();
    }
}

//***********************************************************************************************************
// Composite Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class HideDropDown extends DefaultBehaviour {
    public override function call(param:Any = null):Variant {
        var events:DropDownEvents = cast(_component._internalEvents, DropDownEvents);
        events.hideDropDown();
        return null;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class DataSourceBehaviour extends DefaultBehaviour {
    public override function get():Variant {
        if (_value == null || _value.isNull == true) {
            _value = new ArrayDataSource<Dynamic>();
        }

        return _value;
    }

    public override function set(value:Variant) {
        super.set(value);
        if (value == _value) {
            return;
        }

        var handler:IDropDownHandler = cast(_component._compositeBuilder, DropDownBuilder).handler;
        handler.reset();
        if (_component.text == null && _component.isReady) {
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

    public override function get():Variant {
        if (_component.isReady == false) {
            return super.get();
        }
        var handler:IDropDownHandler = cast(_component._compositeBuilder, DropDownBuilder).handler;
        return handler.selectedIndex;
    }

    public override function set(value:Variant) {
        if (_component.isReady == false) {
            super.set(value);
            return;
        }
        if (value == get()) {
            return;
        }
        _value = value;
        invalidateData();
        var handler:IDropDownHandler = cast(_component._compositeBuilder, DropDownBuilder).handler;
        handler.selectedIndex = _value;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class SelectedItemBehaviour extends DataBehaviour  {
    private override function validateData() {
        var handler:IDropDownHandler = cast(_component._compositeBuilder, DropDownBuilder).handler;
        handler.selectedItem = _value;
    }

    public override function getDynamic():Dynamic {
        var handler:IDropDownHandler = cast(_component._compositeBuilder, DropDownBuilder).handler;
        return handler.selectedItem;
    }

    public override function set(value:Variant) {
        if (_component.isReady == false) {
            super.set(value);
            return;
        }
        if (Variant.toDynamic(value) == getDynamic()) {
            return;
        }
        _value = value;
        invalidateData();
        var handler:IDropDownHandler = cast(_component._compositeBuilder, DropDownBuilder).handler;
        handler.selectedItem = value;
    }
}

//***********************************************************************************************************
// Dropdown Handlers
//***********************************************************************************************************
interface IDropDownHandler {
    var component(get, null):Component;
    function prepare(wrapper:Box):Void;
    function reset():Void;
    var selectedIndex(get, set):Int;
    var selectedItem(get, set):Dynamic;
    function applyDefault():Void;

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

    public function prepare(wrapper:Box) {
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

    public var selectedItem(get, set):Dynamic;
    private function get_selectedItem():Dynamic {
        return null;
    }
    private function set_selectedItem(value:Dynamic):Dynamic {
        return value;
    }

    public function applyDefault() {
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
        if (_listview != null) {
            _listview.dataSource = _dropdown.dataSource;
            /*
            _listview.unregisterEvent(UIEvent.CHANGE, onListChange); // TODO: not great!
            selectedIndex = _cachedSelectedIndex;
            _listview.registerEvent(UIEvent.CHANGE, onListChange); // TODO: not great!
            */
        }
    }

    public override function prepare(wrapper:Box) {
        var itemCount = 4;
        if (_dropdown.dropdownSize != null) {
            itemCount = _dropdown.dropdownSize;
        }
        if (_listview.dataSource != null && _listview.dataSource.size < itemCount) {
            itemCount = _listview.dataSource.size;
        }

        if (itemCount > 0) {
            _listview.itemCount = itemCount;
        }

        if (_dropdown.dropdownWidth == null) {
            wrapper.syncComponentValidation();
            _listview.width = _dropdown.width - (wrapper.layout.paddingLeft + wrapper.layout.paddingRight);
        } else {
            _listview.width = _dropdown.dropdownWidth;
        }
        if (_dropdown.dropdownHeight != null) {
            _listview.height = _dropdown.dropdownHeight;
        }

        var selectedIndex = _dropdown.selectedIndex;
        if (_dropdown.dataSource != null && _dropdown.text != null && selectedIndex < 0) {
            var text = _dropdown.text;
            var itemIndex = indexOfItem(text);
            if (itemIndex != -1) {
                selectedIndex = itemIndex;
            }
        }

        //Screen.instance.addComponent(_listview);
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
        if (_listview != null && _cachedSelectedIndex != value) {
            _cachedSelectedIndex = value;
            _listview.selectedIndex = value;
        } else if (_cachedSelectedIndex != value) {
            _cachedSelectedIndex = value;
            var data = null;
            if (_dropdown.dataSource != null && value >= 0 && value < _dropdown.dataSource.size) {
                data = _dropdown.dataSource.get(value);
            }
            _dropdown.dispatch(new UIEvent(UIEvent.CHANGE, false, data));
        }

        if (_dropdown.dataSource != null && value >= 0 && value < _dropdown.dataSource.size) {
            var data = _dropdown.dataSource.get(value);
            var text = null;
            if (Type.typeof(data) == TObject) {
                text = data.text;
                if (text == null) {
                    text = data.value;
                }
            } else {
                text = Std.string(data);
            }
            _dropdown.text = text;
        }

        return value;
    }

    private function indexOfItem(text:String):Int {
        var index = -1;
        if (_dropdown.dataSource != null) {
            for (i in 0..._dropdown.dataSource.size) {
                var item:Dynamic = _dropdown.dataSource.get(i);
                if (item == text || item.value == text || item.text == text) {
                    index = i;
                }
            }
        }
        
        if (index == -1 && _dropdown.dataSource != null) {
            var info = BindingManager.instance.findLanguageBinding(_dropdown, "text");
            if (info != null && info.script != null) {
                text = info.script;
                for (i in 0..._dropdown.dataSource.size) {
                    var item:Dynamic = _dropdown.dataSource.get(i);
                    if (item == text || item.value == text || item.text == text) {
                        index = i;
                    }
                }
            }
        }
        
        return index;
    }

    private override function get_selectedItem():Dynamic {
        if (_listview == null) {
            if (_cachedSelectedIndex >= 0 && _cachedSelectedIndex < _dropdown.dataSource.size) {
                var data = _dropdown.dataSource.get(_cachedSelectedIndex);
                return data;
            } else {
                return _cachedSelectedItem;
            }
        }
        return _listview.selectedItem;
    }

    private var _cachedSelectedItem:Dynamic = null;
    private override function set_selectedItem(value:Dynamic):Dynamic {
        var v:Variant = value;
        var index:Int = indexOfItem(v);
        if (index == -1 && v.isNumber) {
            index = v;
        }
        selectedIndex = index;
        return value;
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
        var selectedItem = _listview.selectedItem;
        var text = null;
        if (Type.typeof(selectedItem) == TObject) {
            text = _listview.selectedItem.text;
            if (text == null) {
                text = _listview.selectedItem.value;
            }
        } else {
            text = Std.string(selectedItem);
        }
        _dropdown.text = text;
        //_dropdown.selectedIndex = _listview.selectedIndex;
        cast(_dropdown._internalEvents, DropDownEvents).hideDropDown();

        _dropdown.dispatch(new UIEvent(UIEvent.CHANGE, false, selectedItem));
    }

    public override function applyDefault() {
        var indexToSelect = 0;
        if (_cachedSelectedItem != null) {
            var v:Variant = _cachedSelectedItem;
            var index = indexOfItem(v);
            if (index != -1) {
                indexToSelect = index;
            }
        }
        _dropdown.selectedIndex = indexToSelect;
    }
}

@:access(haxe.ui.core.Component)
class CalendarDropDownHandler extends DropDownHandler {
    public static var DATE_FORMAT:String = "%d/%m/%Y";

    private var _calendar:CalendarView;

    private override function get_component():Component {
        if (_calendar == null) {
            _calendar = new CalendarView();
            _calendar.registerEvent(UIEvent.CHANGE, onCalendarChange);
        }
        return _calendar;
    }

    public override function prepare(wrapper:Box) {
        if (_dropdown.dropdownWidth != null) {
            _calendar.width = _dropdown.dropdownWidth;
        }
        if (_dropdown.dropdownHeight != null) {
            _calendar.height = _dropdown.dropdownHeight;
        }

        if (_cachedSelectedDate != null) {
            _calendar.unregisterEvent(UIEvent.CHANGE, onCalendarChange); // TODO: not great!
            _calendar.selectedDate = _cachedSelectedDate;
            _calendar.registerEvent(UIEvent.CHANGE, onCalendarChange); // TODO: not great!
        }

        //Screen.instance.addComponent(_calendar);
        _calendar.syncComponentValidation();
    }

    private var _cachedSelectedDate:Date = null;
    private override function get_selectedItem():Dynamic {
        if (_calendar == null) {
            return _cachedSelectedDate;
        }
        return _calendar.selectedDate;
    }

    private override function set_selectedItem(value:Dynamic):Dynamic {
        if (value == null) {
            return value;
        }
        var v:Variant = value;
        var date:Date = null;
        if (v.isString == true) {
            date = Date.fromString(v);
        } else if (v.isDate) {
            date = v;
        }

        if (_calendar != null && date != null) {
            if (date.toString() == _calendar.selectedDate.toString()) {
                _dropdown.text = DateTools.format(date, DATE_FORMAT);
                return value;
            }
            _cachedSelectedDate = date;
            _calendar.selectedDate = date;
            //_dropdown.text = DateTools.format(date, DATE_FORMAT);
        } else if (date != null) {
            _cachedSelectedDate = date;
            _dropdown.text = DateTools.format(_cachedSelectedDate, DATE_FORMAT);
        }
        return value;
    }

    public function onCalendarChange(event:UIEvent) {
        if (_calendar.selectedDate == null) {
            return;
        }
        _cachedSelectedDate = _calendar.selectedDate;
        _dropdown.text = DateTools.format(_calendar.selectedDate, DATE_FORMAT);
        cast(_dropdown._internalEvents, DropDownEvents).hideDropDown();
        _dropdown.dispatch(new UIEvent(UIEvent.CHANGE, false, _calendar.selectedDate));
    }

    public override function applyDefault() {
        var now = Date.now();
        _dropdown.selectedItem = now;
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
        registerEvent(MouseEvent.MOUSE_DOWN, onClick);
    }

    public override function unregister() {
        super.unregister();
        unregisterEvent(MouseEvent.MOUSE_DOWN, onClick);
    }

    private function onClick(event:MouseEvent) {
        _dropdown.selected = !_dropdown.selected;
        if (_dropdown.selected == true) {
            showDropDown();
        } else {
            hideDropDown();
        }
    }

    private override function onMouseClick(event:MouseEvent) {
        // do nothing
    }

    private var _overlay:Component = null;
    private var _wrapper:Box = null;
    public function showDropDown() {
        var handler:IDropDownHandler = cast(_dropdown._compositeBuilder, DropDownBuilder).handler;
        if (handler == null) {
            return;
        }

        if (_wrapper == null) {
            _wrapper = new Box();
            _wrapper.addClass("popup");
            _wrapper.addClass("dropdown-popup");
            _wrapper.styleNames = _dropdown.handlerStyleNames;
            _wrapper.addComponent(handler.component);

            var filler = new Component();
            filler.horizontalAlign = "right";
            filler.includeInLayout = false;
            filler.addClass("dropdown-filler");
            filler.id = "dropdown-filler";
            _wrapper.addComponent(filler);
        }

        var componentOffset = _dropdown.getComponentOffset();

        if (_dropdown.style.mode != null && _dropdown.style.mode == "mobile") {
            if (_overlay == null) {
                _overlay = new Component();
                _overlay.id = "modal-background";
                _overlay.addClass("modal-background");
                _overlay.percentWidth = _overlay.percentHeight = 100;
            }
            Screen.instance.addComponent(_overlay);

            handler.prepare(_wrapper);
            Screen.instance.addComponent(_wrapper);
            _wrapper.left = (Screen.instance.width / 2) - (_wrapper.actualComponentWidth / 2);
            _wrapper.top = (Screen.instance.height / 2) - (_wrapper.actualComponentHeight / 2);
        } else {
            _wrapper.left = _dropdown.screenLeft + componentOffset.x;
            _wrapper.top = _dropdown.screenTop + (_dropdown.actualComponentHeight - Toolkit.scaleY) + componentOffset.y;
            Screen.instance.addComponent(_wrapper);
            handler.prepare(_wrapper);
            _wrapper.syncComponentValidation();

            var cx = _wrapper.width - _dropdown.width;
            var filler:Component = _wrapper.findComponent("dropdown-filler", false);
            if (cx > 0 && filler != null) {
                _wrapper.addClass("dropdown-popup-expanded");
                cx += 2;
                filler.width = cx;
                filler.left = _wrapper.width - cx;
                filler.hidden = false;
            } else if (filler != null) {
                filler.hidden = true;
                _wrapper.removeClass("dropdown-popup-expanded");
            }

            if (_wrapper.screenLeft + _wrapper.actualComponentWidth > Screen.instance.width) {
                _wrapper.left = _wrapper.screenLeft - _wrapper.actualComponentWidth + _dropdown.actualComponentWidth;
            }
            if (_wrapper.screenTop + _wrapper.actualComponentHeight > Screen.instance.height) {
                _wrapper.top = _dropdown.screenTop - _wrapper.actualComponentHeight;
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

        if (_wrapper != null) {
            Screen.instance.removeComponent(_wrapper);
        }
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
        Screen.instance.unregisterEvent(MouseEvent.RIGHT_MOUSE_DOWN, onScreenMouseDown);
    }

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

    // override and do nothing
    private override function dispatchChanged() {
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.components.DropDownEvents)
class DropDownBuilder extends ButtonBuilder {

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

    public override function onReady() {
        super.onReady();
        if (_dropdown.text == null) {
            handler.applyDefault();
        }
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

    @:access(haxe.ui.core.Screen)
    public function onThemeChanged() {
        if (_handler != null) {
            Screen.instance.invalidateChildren(_handler.component);
            Screen.instance.onThemeChangedChildren(_handler.component);
        }
    }
}
