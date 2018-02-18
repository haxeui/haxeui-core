package haxe.ui.core;

import haxe.ui.focus.IFocusable;

/**
 A component that can be interacted with and gain input focus via either mouse or keyboard
**/
class InteractiveComponent extends Component implements IFocusable {
    public function new() {
        super();
    }

    private var _focus:Bool = false;
    /**
     Whether this component currently has focus

     *Note*: components that have focus will have an `:active` css psuedo class automatically added
    **/
    public var focus(get, set):Bool;
    private function get_focus():Bool {
        return _focus;
    }
    private function set_focus(value:Bool):Bool {
        if (_focus == value || allowFocus == false) {
            return value;
        }

        _focus = value;
        if (_focus == true) {
            addClass(":active");
        } else {
            removeClass(":active");
        }
        return value;
    }

    private var _allowFocus:Bool = true;
    /**
     Whether this component is allowed to gain focus
    **/
    public var allowFocus(get, set):Bool;
    private function get_allowFocus():Bool {
        return _allowFocus;
    }
    private function set_allowFocus(value:Bool):Bool {
        if (_allowFocus == value) {
            return value;
        }

        _allowFocus = value;
        return value;
    }
}