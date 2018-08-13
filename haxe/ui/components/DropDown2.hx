package haxe.ui.components;

import haxe.ui.components.Button.ButtonEvents;
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
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
}

//***********************************************************************************************************
// Dropdown Handlers
//***********************************************************************************************************
interface IDropDownHandler {
    function show():Void;
    function hide():Void;
}

class DropDownHandler implements IDropDownHandler {
    private var _dropdown:DropDown2;
    
    public function new(dropdown:DropDown2) {
        _dropdown = dropdown;
    }
    
    public function show() {
    }
    
    public function hide() {
    }
}

class ListDropDownHandler extends DropDownHandler {
    private var _listview:ListView2;
    
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
        
        _listview.left = _dropdown.screenLeft;
        _listview.top = _dropdown.screenTop + _dropdown.height;
        _listview.width = _dropdown.width;
        _listview.height = (calcItemHeight() * listSize()) + _listview.style.paddingTop + _listview.style.paddingBottom;
        
        if (_listview.screenTop + _listview.height > Screen.instance.height) {
            _listview.top = _dropdown.screenTop - _listview.height;
        }
        
        Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
    }
    
    public override function hide() {
        if (_listview == null) {
            return;
        }
        
        Screen.instance.removeComponent(_listview);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
    }
    
    private function onListChange(event:UIEvent) {
        var label = _listview.selectedItem.findComponent(Label, true);
        var text = null;
        if (label != null) {
            text = label.text;
        }
        _dropdown.text = text;
        hide();
        _dropdown.selected = false;
    }
    
    private function onScreenMouseDown(event:MouseEvent) {
        if (_listview.hitTest(event.screenX, event.screenY) == true) {
            return;
        }
        if (_dropdown.hitTest(event.screenX, event.screenY) == true) {
            return;
        }
        hide();
        _dropdown.selected = false;
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
        var contents:Component = _listview.findComponent("listview-contents", false, "css");
        var n = 4;
        if (n > contents.childComponents.length) {
            n = contents.childComponents.length;
        }
        return n;
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
    
    private function showDropDown() {
        if (_handler == null) {
            _handler = new ListDropDownHandler(_dropdown); // TODO: make this an option
        }
        
        _handler.show();
    }
    
    private function hideDropDown() {
        if (_handler == null) {
            return;
        }
        
        _handler.hide();
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class DropDownBuilder extends CompositeBuilder {
    private var _dropdown:DropDown2;

    public function new(dropdown:DropDown2) {
        super(dropdown);
        _dropdown = dropdown;
    }
    
    public override function create() {
        _dropdown.toggle = true;
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
