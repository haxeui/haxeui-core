package haxe.ui.core;

import haxe.ui.core.Component;
import haxe.ui.core.IClonable;
import haxe.ui.core.MouseEvent;
import haxe.ui.util.Variant;

class ItemRenderer extends Component implements IClonable<ItemRenderer> {
    public function new() {
        super();
        registerEvent(MouseEvent.MOUSE_OVER, onMouseOver);
        registerEvent(MouseEvent.MOUSE_OUT, onMouseOut);
    }
    
    private function onMouseOver(event:MouseEvent) {
        addClass(":hover");
    }
    
    private function onMouseOut(event:MouseEvent) {
        removeClass(":hover");
    }
    
    private var _data:Dynamic;
    public var data(get, set):Dynamic;
    private function get_data():Dynamic {
        return _data;
    }
    private function set_data(value:Dynamic):Dynamic {
        _data = value;
        for (f in Reflect.fields(_data)) {
            var v = Reflect.field(_data, f);
            var c:Component = findComponent(f, null, true);
            if (c != null) {
                c.value = Variant.fromDynamic(v);
            }
        }
        return value;
    }
}