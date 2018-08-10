package haxe.ui.components;

import haxe.ui.containers.ListView;
import haxe.ui.core.BasicItemRenderer;
import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.Screen;
import haxe.ui.core.UIEvent;
import haxe.ui.data.DataSource;
import haxe.ui.util.Variant;

class DropDown extends Button implements IDataComponent {
    static private inline var NO_SELECTION:Int = -1;

    private var _listview:ListView;
    private var _itemRenderer:ItemRenderer;

    public function new() {
        super();
        toggle = true;
        registerEvent(MouseEvent.CLICK, onMouseClick);
    }

    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "dataSource" => new DropDownDefaultDataSourceBehaviour(this),
            "selectedItem" => new DropDownDefaultSelectedItemBehaviour(this)
        ]);
    }

    private override function create() {
        super.create();
    }

    private override function createChildren() {
        super.createChildren();
    }

    private override function destroyChildren() {
        super.destroyChildren();
        unregisterEvent(MouseEvent.CLICK, onMouseClick);
    }

    private override function onReady() {
        super.onReady();
        if (_itemRenderer == null) {
            addComponent(new BasicItemRenderer());
        }
    }

    private override function onDestroy() {
        hideList();
    }

    private var _dataSource:DataSource<Dynamic>;
    public var dataSource(get, set):DataSource<Dynamic>;
    private function get_dataSource():DataSource<Dynamic> {
        return _dataSource;
    }
    private function set_dataSource(value:DataSource<Dynamic>):DataSource<Dynamic> {
        if (_dataSource == value) {
            return value;
        }

        invalidateComponentData();
        _dataSource = value;
        return value;
    }

    private var _selectedIndex:Int = NO_SELECTION;
    @bindable public var selectedIndex(get, set):Int;
    private function get_selectedIndex():Int {
        return _selectedIndex;
    }
    private function set_selectedIndex(value:Int):Int {
        if(_dataSource == null || value >= _dataSource.size) {
            return value;
        }

        if(_selectedIndex == value) {
            return value;
        }

        invalidateComponentData();
        _selectedIndex = value;
        return _selectedIndex;
    }

    private var _requireSelection:Bool = false;
    public var requireSelection(get, set):Bool;
    private function get_requireSelection():Bool {
        return _requireSelection;
    }
    private function set_requireSelection(value:Bool):Bool {
        if(_requireSelection == value) {
            return value;
        }

        invalidateComponentData();
        _requireSelection = value;
        return value;
    }

    private var _listWidth:Null<Float>;
    public var listWidth(get, set):Null<Float>;
    private function get_listWidth():Null<Float> {
        return _listWidth;
    }
    private function set_listWidth(value:Null<Float>):Null<Float> {
        _listWidth = value;
        return value;
    }

    private var _listHeight:Null<Float>;
    public var listHeight(get, set):Null<Float>;
    private function get_listHeight():Null<Float> {
        return _listHeight;
    }
    private function set_listHeight(value:Null<Float>):Null<Float> {
        _listHeight = value;
        return value;
    }

    private var _listSize:Int = 4;
    public var listSize(get, set):Int;
    private function get_listSize():Int {
        return _listSize;
    }
    private function set_listSize(value:Int):Int {
        _listSize = value;
        return value;
    }

    private var _listStyleNames:String;
    public var listStyleNames(get, set):String;
    private function get_listStyleNames():String {
        return _listStyleNames;
    }
    private function set_listStyleNames(value:String):String {
        _listStyleNames = value;
        return value;
    }

    public override function addComponent(child:Component):Component {
        var r = null;
        if (Std.is(child, ItemRenderer) && _itemRenderer == null) {
            _itemRenderer = cast(child, ItemRenderer);
            #if haxeui_luxe
            _itemRenderer.hide();
            #end
        } else {
            r = super.addComponent(child);
        }
        return r;
    }

    private function onMouseClick(event:MouseEvent) {
        if (native == true) {
            return;
        }

        if (selected == true) {
            showList();
        } else {
            hideList();
        }
    }

    public var selectedItem(get, null):Dynamic;
    private function get_selectedItem():Dynamic {
        return behaviourGetDynamic("selectedItem");
    }

    private function onItemChange(event:UIEvent) {
        if (_listview.selectedItem != null && _listview.selectedItem.data != null) {
            selectedIndex = _dataSource.indexOf(_listview.selectedItem.data);
        }
        selected = false;
        onMouseClick(null);
        dispatch(new UIEvent(UIEvent.CHANGE));
    }

    private function onScreenMouseDown(event:MouseEvent) {
        if (hitTest(event.screenX, event.screenY) == true) {
            return;
        }
        if (_listview != null && _listview.hitTest(event.screenX, event.screenY) == true) {
            return;
        }
        
        selected = !selected;
        onMouseClick(null);
    }

    private function showList() {
        if (_listview == null) {
            _listview = new ListView();
            if (_itemRenderer != null) {
                _listview.addComponent(_itemRenderer);
            }
            _listview.addClass("popup");
            if (id != null) {
                _listview.id = id + "-popup";
                _listview.addClass(id + "-popup");
            }
            if (_listStyleNames != null) {
                for (s in _listStyleNames.split(" ")) {
                    _listview.addClass(s);
                }
            }
            if (_dataSource != null) {
                _listview.dataSource = _dataSource;
            }
            _listview.registerEvent(UIEvent.CHANGE, onItemChange);
        }
        Screen.instance.addComponent(_listview);

        _listview.left = this.screenLeft;
        _listview.top = this.screenTop + this.componentHeight;
        if (_listWidth == null) {
            _listview.width = Math.ffloor(this.componentWidth);
        } else {
            _listview.width = _listWidth;
        }

        var listHeight = _listHeight;
        if (_listHeight == null) {
            var n:Int = _listSize;
            if (n > _listview.itemCount) {
                n = _listview.itemCount;
            }
            _listview.syncValidation();
            listHeight = n * _listview.itemHeight + (_listview.layout.paddingTop + _listview.layout.paddingBottom);
        }
        _listview.height = listHeight;
        _listview.selectedIndex = _selectedIndex;
        _listview.syncValidation();     //avoid ui flash in some backends

        if (_listview.screenTop + _listview.height > Screen.instance.height) {
            _listview.top = this.screenTop - _listview.height;
        }

        Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
    }

    private function hideList() {
        if (_listview != null) {
            if (_listview.selectedItem != null) {
                _listview.selectedItem.removeClass(":hover");
            }
            Screen.instance.removeComponent(_listview);
        }
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
    }

    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************

    private override function validateData() {
        if (_listview != null) {
            _listview.dataSource = _dataSource;
        }

        behaviourSet("dataSource", _dataSource);    //TODO - if the index is the only change, the syncUI method is executed anyway

        if(_dataSource != null) {
            if(_requireSelection == true && _selectedIndex < 0 && _dataSource.size > 0) {
                _selectedIndex = 0;
            }

            if(_selectedIndex >= 0) {
                _text = _dataSource.get(_selectedIndex).value;
            }
        } else {
            //_text = null;
        }

        super.validateData();
    }

    //***********************************************************************************************************
    // Clonable
    //***********************************************************************************************************
    public override function cloneComponent():DropDown {
        if (_dataSource != null) {
            c.dataSource = _dataSource.clone();
        }
    }
}

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************

@:dox(hide)
class DropDownDefaultDataSourceBehaviour extends Behaviour {
    public override function set(value:Variant) {

    }
}

@:dox(hide)
@:access(haxe.ui.components.DropDown)
class DropDownDefaultSelectedItemBehaviour extends Behaviour {
    public override function getDynamic():Dynamic {
        var dropDown:DropDown = cast(_component, DropDown);
        var lv:ListView = dropDown._listview;
        if (dropDown.dataSource == null || dropDown._selectedIndex == DropDown.NO_SELECTION) {
            return null;
        }
        return dropDown.dataSource.get(dropDown._selectedIndex);
    }
}
