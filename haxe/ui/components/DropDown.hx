package haxe.ui.components;

import haxe.ui.Toolkit;
import haxe.ui.actions.ActionType;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.behaviours.DynamicDataBehaviour;
import haxe.ui.components.Button.ButtonBuilder;
import haxe.ui.components.Button.ButtonEvents;
import haxe.ui.components.TextField;
import haxe.ui.containers.Box;
import haxe.ui.containers.CalendarView;
import haxe.ui.containers.HBox;
import haxe.ui.containers.ListView;
import haxe.ui.containers.VBox;
import haxe.ui.core.BasicItemRenderer;
import haxe.ui.core.Component;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.core.Screen;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.data.DataSource;
import haxe.ui.events.ActionEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.locale.Formats;
import haxe.ui.locale.LocaleManager;
import haxe.ui.util.Variant;

@:composite(DropDownEvents, DropDownBuilder)
class DropDown extends Button implements IDataComponent {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(DefaultBehaviour)                        public var handlerStyleNames:String;
    @:clonable @:behaviour(DataSourceBehaviour)                     public var dataSource:DataSource<Dynamic>;
    @:clonable @:behaviour(DefaultBehaviour, "list")                public var type:String;
    @:clonable @:behaviour(DefaultBehaviour, false)                 public var virtual:Bool;
    @:clonable @:behaviour(DefaultBehaviour)                        public var dropdownWidth:Null<Float>;
    @:clonable @:behaviour(DefaultBehaviour)                        public var dropdownHeight:Null<Float>;
    @:clonable @:behaviour(DefaultBehaviour)                        public var dropdownSize:Null<Int>;
    @:clonable @:behaviour(SelectedIndexBehaviour, -1)              public var selectedIndex:Int;
    @:clonable @:behaviour(SelectedItemBehaviour)                   public var selectedItem:Dynamic;
    @:clonable @:behaviour(DefaultBehaviour, false)                 public var searchable:Bool;
    @:clonable @:behaviour(DefaultBehaviour, "{{search}}")          public var searchPrompt:String;
    @:clonable @:value(selectedItem)                                public var value:Dynamic;
    @:clonable @:behaviour(SearchFieldBehaviour)                    public var searchField:Component;
    @:call(HideDropDown)                                            public function hideDropDown();
    @:call(ShowDropDown)                                            public function showDropDown();

    private var _itemRenderer:ItemRenderer = null;
    @:clonable public var itemRenderer(get, set):ItemRenderer;
    private function get_itemRenderer():ItemRenderer {
        return _itemRenderer;
    }
    private function set_itemRenderer(value:ItemRenderer):ItemRenderer {
        _itemRenderer = value;
        return value;
    }
    
    private override function onThemeChanged() {
        super.onThemeChanged();
        var builder:DropDownBuilder = cast(this._compositeBuilder, DropDownBuilder);
        builder.onThemeChanged();
    }

    private override function postCloneComponent(c:Component) {
        super.postCloneComponent(c);
        if (_itemRenderer != null) {
            c.addComponent(_itemRenderer.cloneComponent());
        }
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
private class ShowDropDown extends DefaultBehaviour {
    public override function call(param:Any = null):Variant {
        var events:DropDownEvents = cast(_component._internalEvents, DropDownEvents);
        events.showDropDown();
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
private class SelectedItemBehaviour extends DynamicDataBehaviour  {
    private override function validateData() {
        var handler:IDropDownHandler = cast(_component._compositeBuilder, DropDownBuilder).handler;
        handler.selectedItem = _value;
    }

    public override function getDynamic():Dynamic {
        var handler:IDropDownHandler = cast(_component._compositeBuilder, DropDownBuilder).handler;
        return handler.selectedItem;
    }

    public override function setDynamic(value:Dynamic) {
        if (_component.isReady == false) {
            super.setDynamic(value);
            return;
        }
        
        _value = value;
        invalidateData();
        var handler:IDropDownHandler = cast(_component._compositeBuilder, DropDownBuilder).handler;
        handler.selectedItem = value;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class SearchFieldBehaviour extends DefaultBehaviour {
    public override function get():Variant {
        var events:DropDownEvents = cast(_component._internalEvents, DropDownEvents);
        return events.searchField;
    }
    
    public override function set(value:Variant) {
        var events:DropDownEvents = cast(_component._internalEvents, DropDownEvents);
        events.searchField = cast value.toComponent();
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
    function pauseEvents():Void;
    function resumeEvents():Void;

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
    
    private var eventsPaused:Bool = false;
    public function pauseEvents() {
        eventsPaused = true;
    }
    
    public function resumeEvents() {
        Toolkit.callLater(function() {
            eventsPaused = false;
        });
    }
}

@:access(haxe.ui.core.Component)
private class ListDropDownHandler extends DropDownHandler {
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

        if (itemCount > 0 && _dropdown.dropdownHeight == null) {
            _listview.itemCount = itemCount;
        }

        _listview.syncComponentValidation();
        if (_dropdown.dropdownWidth == null) {
            wrapper.syncComponentValidation();
            var offset:Float = 0;
            if (wrapper.layout != null) {
                offset = wrapper.layout.paddingLeft + wrapper.layout.paddingRight;
            }
            _listview.width = _dropdown.width - offset;
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
        var data = null;
        var dispatchChanged:Bool = false;
        if (_listview != null && _cachedSelectedIndex != value) {
            _cachedSelectedIndex = value;
            _listview.selectedIndex = value;
        } else if (_cachedSelectedIndex != value) {
            _cachedSelectedIndex = value;
            if (_dropdown.dataSource != null && value >= 0 && value < _dropdown.dataSource.size) {
                data = _dropdown.dataSource.get(value);
            }
            dispatchChanged = true;
        }

        if (_dropdown.dataSource != null && value >= 0 && value < _dropdown.dataSource.size) {
            var data = _dropdown.dataSource.get(value);
            var itemRenderer = _dropdown.findComponent(ItemRenderer);
            if (itemRenderer == null) {
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
            } else {
                itemRenderer.data = data;
            }
        }
        
        if (dispatchChanged) {
            var event = new UIEvent(UIEvent.CHANGE, false, data);
            event.value = Variant.fromDynamic(data);
            _dropdown.dispatch(event);
        }

        return value;
    }

    private function indexOfItem(text:String):Int {
        if (text == null) {
            return -1;
        }
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
            var expr = LocaleManager.instance.findBindingExpr(_dropdown, "text");
            if (expr != null) {
                text = expr;
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
        if (value == null) {
            return value;
        }

        var text = null;
        if (Type.typeof(value) == TObject) {
            text = value.text;
            if (text == null) {
                text = value.value;
            }
        } else {
            text = Std.string(value);
        }
        
        var index:Int = indexOfItem(text);
        selectedIndex = index;
        return value;
    }

    private function createListView() {
        if (_listview == null) {
            _listview = new ListView();
            if (_dropdown.itemRenderer != null) {
                _listview.addComponent(_dropdown.itemRenderer);
            }
            _listview.componentTabIndex = -1;
            _listview.virtual = _dropdown.virtual;
            _listview.dataSource = _dropdown.dataSource;
            if (_cachedSelectedIndex != -1) {
                _listview.selectedIndex = _cachedSelectedIndex;
            }
            
            if (_dropdown.id != null) {
                _listview.addClass(_dropdown.id + "-listview");
                _listview.id = _dropdown.id + "_listview";
            }

            _listview.registerEvent(ActionEvent.ACTION_START, function(e:ActionEvent) {
                switch (e.action) {
                    case ActionType.BACK | ActionType.CANCEL:
                        e.cancel();
                        cast(_dropdown._internalEvents, DropDownEvents).hideDropDown();
                    case ActionType.CONFIRM | ActionType.PRESS:
                        e.cancel();
                        applySelection();
                    case _:    
                }
            });
        }
    }

    private function onListChange(event:UIEvent) {
        if ((event.relatedEvent is MouseEvent)) {
            applySelection();
        }
    }
    
    private function applySelection() {
        if (_listview.selectedItem == null) {
            return;
        }
        var currentHover:Component = _listview.findComponent(":hover", null, true, "css");
        if (currentHover != null) { // since the dropdown list dissapears it doesnt recvieve a mouse out (sometimes)
            currentHover.removeClass(":hover");
        }
        var selectedItem = _listview.selectedItem;
        var itemRenderer = _dropdown.findComponent(ItemRenderer);
        if (itemRenderer == null) {
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
        } else {
            itemRenderer.data = selectedItem;
        }
        
        //_dropdown.selectedIndex = _listview.selectedIndex;
        
        if (eventsPaused == false) {
            cast(_dropdown._internalEvents, DropDownEvents).hideDropDown();
            var event = new UIEvent(UIEvent.CHANGE, false, selectedItem);
            event.value = Variant.fromDynamic(selectedItem);
            _dropdown.dispatch(event);
        }
    }

    public override function applyDefault() {
        var indexToSelect = 0;
        if (_cachedSelectedItem != null) {
            var index = indexOfItem(_cachedSelectedItem);
            if (index != -1) {
                indexToSelect = index;
            }
        } else if (_cachedSelectedIndex != -1) {
            indexToSelect = _cachedSelectedIndex;
        }
        _dropdown.selectedIndex = indexToSelect;
    }
}

@:access(haxe.ui.core.Component)
class CalendarDropDownHandler extends DropDownHandler {
    private var _calendar:CalendarView;

    private override function get_component():Component {
        if (_calendar == null) {
            _calendar = new CalendarView();
            if (_dropdown.id != null) {
                _calendar.addClass(_dropdown.id + "-calendar");
                _calendar.id = _dropdown.id + "_calendar";
            }
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

        var date:Date = null;
        if ((value is Date)) {
            date = cast(value, Date);
        } else {
            date = Date.fromString(Std.string(value));
        }

        if (_calendar != null && date != null) {
            if (date.toString() == _calendar.selectedDate.toString()) {
                _dropdown.text = DateTools.format(date, Formats.dateFormatShort);
                return value;
            }
            _cachedSelectedDate = date;
            _calendar.selectedDate = date;
            //_dropdown.text = DateTools.format(date, DATE_FORMAT);
        } else if (date != null) {
            _cachedSelectedDate = date;
            _dropdown.text = DateTools.format(_cachedSelectedDate, Formats.dateFormatShort);
        }
        return value;
    }

    public function onCalendarChange(event:UIEvent) {
        if (_calendar.selectedDate == null) {
            return;
        }
        _cachedSelectedDate = _calendar.selectedDate;
        _dropdown.text = DateTools.format(_calendar.selectedDate, Formats.dateFormatShort);
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
            if (_button.id != null) {
                _wrapper.addClass(_button.id + "-popup");
                _wrapper.id = _button.id + "_popup";
            } else {
                _wrapper.id = "dropdown_popup";
            }
            _wrapper.styleNames = _dropdown.handlerStyleNames;
            
            if (_dropdown.searchable == true) {
                var searchContainer = new VBox();
                searchContainer.id = "dropdown-search-container";
                searchContainer.addClass("dropdown-search-container");
                searchContainer.scriptAccess = false;

                var searchFieldContainer = new HBox();
                searchFieldContainer.id = "dropdown-search-field-container";
                searchFieldContainer.addClass("dropdown-search-field-container");
                searchFieldContainer.scriptAccess = false;
                searchFieldContainer.addComponent(searchField);
                
                var searchFieldSeparator = new Component();
                searchFieldSeparator.id = "dropdown-search-field-separator";
                searchFieldSeparator.addClass("dropdown-search-field-separator");
                searchFieldSeparator.scriptAccess = false;
                
                searchContainer.addComponent(searchFieldContainer);
                searchContainer.addComponent(searchFieldSeparator);
                searchContainer.addComponent(handler.component);
                _wrapper.addComponent(searchContainer);
            } else {
                _wrapper.addComponent(handler.component);
            }

            if (_dropdown.style.fontSize != null && handler.component.customStyle.fontSize != _dropdown.style.fontSize) {
                handler.component.customStyle.fontSize = _dropdown.style.fontSize;
            }
            
            var filler = new Component();
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

            Screen.instance.addComponent(_wrapper);
            handler.prepare(_wrapper);
            _wrapper.syncComponentValidation();
            _wrapper.validateNow();
            _wrapper.left = (Screen.instance.actualWidth / 2) - (_wrapper.actualComponentWidth / 2);
            _wrapper.top = (Screen.instance.actualHeight / 2) - (_wrapper.actualComponentHeight / 2);
        } else {
            _wrapper.left = _dropdown.screenLeft + componentOffset.x;
            _wrapper.top = _dropdown.screenTop + (_dropdown.actualComponentHeight - Toolkit.scaleY) + componentOffset.y;
            Screen.instance.addComponent(_wrapper);
            handler.prepare(_wrapper);
            _wrapper.syncComponentValidation();
            _wrapper.validateNow();

            var popupToRight = false;
            var popupFromBottom = false;
            if (_wrapper.screenLeft + _wrapper.actualComponentWidth > Screen.instance.actualWidth) {
                var left = _wrapper.screenLeft - _wrapper.actualComponentWidth + _dropdown.actualComponentWidth;
                _wrapper.left = left >= 0 ? left : (Screen.instance.actualWidth / 2) - (_wrapper.actualComponentWidth / 2);
                popupToRight = true;
            }
            _wrapper.removeClass("popup-from-bottom");
            if (_wrapper.screenTop + _wrapper.actualComponentHeight > Screen.instance.actualHeight) {
                _wrapper.top = (_dropdown.screenTop - _wrapper.actualComponentHeight) + Toolkit.scaleY;
                popupFromBottom = true;
                _wrapper.addClass("popup-from-bottom");
            }
            
            var cx = _wrapper.width - _dropdown.width;
            var filler:Component = _wrapper.findComponent("dropdown-filler", false);
            if (cx > 0 && filler != null) {
                _wrapper.addClass("dropdown-popup-expanded");
                filler.width = cx;
                if (popupToRight) {
                    cx -= Toolkit.scaleX;
                    filler.left = Toolkit.scaleX;
                } else {
                    cx += Toolkit.scaleX;
                    filler.left = _wrapper.width - cx;
                }
                
                if (popupFromBottom) {
                    filler.top = _wrapper.actualComponentHeight - Toolkit.scaleY;
                } else {
                    filler.top = 0;
                }
                
                filler.hidden = false;
            } else if (filler != null) {
                filler.hidden = true;
                _wrapper.removeClass("dropdown-popup-expanded");
            }

        }

        Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
        Screen.instance.registerEvent(MouseEvent.RIGHT_MOUSE_DOWN, onScreenMouseDown);
        registerEvent(UIEvent.MOVE, onDropDownMoved);
    }
    
    private function onDropDownMoved(_) {
        hideDropDown();
    }
    
    public function createSearchField():TextField {
        var searchField = new TextField();
        searchField.registerEvent(ActionEvent.ACTION_START, function(e:ActionEvent) {
            if (e.action == ActionType.DOWN || e.action == ActionType.UP ||
                e.action == ActionType.CONFIRM || e.action == ActionType.PRESS ||
                e.action == ActionType.BACK || e.action == ActionType.CANCEL) {
                var builder:DropDownBuilder = cast(_dropdown._compositeBuilder, DropDownBuilder);
                builder.handler.component.dispatch(e);
            }
        });
        searchField.id = "dropdown-search-field";
        searchField.addClass("dropdown-search-field");
        searchField.placeholder = _dropdown.searchPrompt;
        searchField.scriptAccess = false;
        searchField.registerEvent(UIEvent.CHANGE, onSearchChange);
        return searchField;
    }
    
    private var _searchField:TextField = null;
    public var searchField(get, set):TextField;
    private function get_searchField():TextField {
        if (_searchField == null) {
            _searchField = createSearchField();
        }
        return _searchField;
    }
    private function set_searchField(value:TextField):TextField {
        _searchField = value;
        return value;
    }

    private var _lastSearchTerm = "";
    private function onSearchChange(event:UIEvent) {
        if (_wrapper == null) {
            return;
        }
        var searchField = _wrapper.findComponent("dropdown-search-field", TextField);
        if (searchField == null) {
            return;
        }
        
        var selectedItem = _dropdown.selectedItem;
        var searchTerm = searchField.text;
        if (searchTerm == null || StringTools.trim(searchTerm).length == 0) {
            searchTerm = "";
        }
        if (_lastSearchTerm == searchTerm) {
            return;
        }
        _lastSearchTerm = searchTerm;
        if (searchTerm.length == 0) {
            _dropdown.dataSource.clearFilter();
        } else {
            _dropdown.dataSource.filter(function(index, data) {
                var v = data.text;
                return Std.string(v).toLowerCase().indexOf(searchTerm.toLowerCase()) > -1;
            });
        }

        var handler:IDropDownHandler = cast(_dropdown._compositeBuilder, DropDownBuilder).handler;
        if (handler == null) {
            return;
        }
        
        handler.prepare(_wrapper);
        if (selectedItem != null) {
            handler.pauseEvents();
            _dropdown.selectedItem = selectedItem;
            handler.resumeEvents();
        }
    }
    
    public function hideDropDown() {
        var handler:IDropDownHandler = cast(_dropdown._compositeBuilder, DropDownBuilder).handler;
        if (handler == null) {
            return;
        }

        if (_wrapper != null) {
            var searchField = _wrapper.findComponent("dropdown-search-field", TextField);
            if (searchField != null) {
                searchField.focus = false;
            }
        }
        
        if (_overlay != null) {
            Screen.instance.removeComponent(_overlay);
            _overlay = null;
        }

        _dropdown.selected = false;

        if (_wrapper != null) {
            Screen.instance.removeComponent(_wrapper, false);
        }
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
        Screen.instance.unregisterEvent(MouseEvent.RIGHT_MOUSE_DOWN, onScreenMouseDown);
        unregisterEvent(UIEvent.MOVE, onDropDownMoved);
    }

    private function onScreenMouseDown(event:MouseEvent) {
        if (_wrapper == null) {
            return;
        }
        if (_wrapper.hitTest(event.screenX, event.screenY) == true) {
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
    
    private override function release() {
        if (_down == true) {
            super.release();
            if (_dropdown.selected == true) {
                showDropDown();
            } else {
                hideDropDown();
            }
        }
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
        if (_dropdown.findComponent(ItemRenderer) == null) {
            _dropdown.addComponent(new BasicItemRenderer());
        }
    }

    public override function destroy() {
        var events:DropDownEvents = cast(_dropdown._internalEvents, DropDownEvents);
        events.hideDropDown();
        if (events._wrapper != null) {
            Screen.instance.removeComponent(events._wrapper);
            events._wrapper = null;
        }
    }

    public override function addComponent(child:Component):Component {
        if ((child is ItemRenderer)) {
            _dropdown.itemRenderer = cast child.cloneComponent();
            if (child.id == "dropdown-renderer" || child.id == "dropdownRenderer") {
                return child;
            }
        }
        return super.addComponent(child);
    }
    
    @:access(haxe.ui.core.Screen)
    public function onThemeChanged() {
        if (_handler != null) {
            Screen.instance.invalidateChildren(_handler.component);
            Screen.instance.onThemeChangedChildren(_handler.component);
        }
    }
}
