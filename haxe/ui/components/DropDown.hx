package haxe.ui.components;
import haxe.ui.containers.ListView;
import haxe.ui.core.IClonable;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.Screen;
import haxe.ui.core.UIEvent;

class DropDown extends Button implements IDataComponent implements IClonable<DropDown> {
    private var _listview:ListView;
    
    public function new() {
        super();
        addClass("button"); // TODO: shouldnt have to do this
        toggle = true;
        registerEvent(MouseEvent.CLICK, onMouseClick);
    }
    
    private var _data:Dynamic;
    public var data(get, set):Dynamic;
    private function get_data():Dynamic {
        return null;
    }
    private function set_data(value:Dynamic):Dynamic {
        _data = value;
        return value;
    }
    
    private function onMouseClick(event:MouseEvent) {
        if (selected == true) {
            if (_listview == null) {
                _listview = new ListView();
                _listview.addClass("popup");
                _listview.addComponent(new BasicItemRenderer());
                if (_data != null) {
                    _listview.data = _data;
                }
                /*
                _listview.addItem( { text:"item 1" } );
                _listview.addItem( { text:"item 2" } );
                _listview.addItem( { text:"item 3" } );
                _listview.addItem( { text:"item 4" } );
                _listview.addItem( { text:"item 5" } );
                _listview.addItem( { text:"item 6" } );
                _listview.addItem( { text:"item 7" } );
                */
                _listview.registerEvent(UIEvent.CHANGE, onItemChange);
            }
            
            _listview.left = this.screenLeft;
            _listview.top = this.screenTop + this.componentHeight;
            _listview.width = Math.ffloor(this.componentWidth);
            _listview.height = 105; // TODO: create a DropDown.listSize (need a ListView.itemHeight to work)
            
            Screen.instance.addComponent(_listview);
            Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
        } else {
            if (_listview != null) {
                Screen.instance.removeComponent(_listview);
            }
            Screen.instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
        }
    }
    
    private function onItemChange(event:UIEvent) {
        if (_listview.selectedItem.data.text != null) {
            this.text = _listview.selectedItem.data.text;
        }
        selected = false;
        onMouseClick(null);
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
    
}

