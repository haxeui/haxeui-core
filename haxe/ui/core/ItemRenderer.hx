package haxe.ui.core;

import haxe.ui.util.Variant;

class ItemRenderer extends Component {
    public function new() {
        super();
        registerEvent(MouseEvent.MOUSE_OVER, _onItemMouseOver);
        registerEvent(MouseEvent.MOUSE_OUT, _onItemMouseOut);
    }

    private function _onItemMouseOver(event:MouseEvent) {
        addClass(":hover");
    }

    private function _onItemMouseOut(event:MouseEvent) {
        removeClass(":hover");
    }

    private var _allowHover:Bool = true;
    @clonable public var allowHover(get, set):Bool;
    private function get_allowHover():Bool {
        return _allowHover;
    }
    private function set_allowHover(value:Bool):Bool {
        if (_allowHover == value) {
            return value;
        }
        _allowHover = value;
        if (_allowHover == true) {
            registerEvent(MouseEvent.MOUSE_OVER, _onItemMouseOver);
            registerEvent(MouseEvent.MOUSE_OUT, _onItemMouseOut);
        } else {
            unregisterEvent(MouseEvent.MOUSE_OVER, _onItemMouseOver);
            unregisterEvent(MouseEvent.MOUSE_OUT, _onItemMouseOut);
        }
        return value;
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
            if (c != null && v != null) {
                c.value = Variant.fromDynamic(v);
            }
        }
        return value;
    }
}