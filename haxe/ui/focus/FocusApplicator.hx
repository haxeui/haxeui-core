package haxe.ui.focus;

import haxe.ui.core.Component;

class FocusApplicator implements IFocusApplicator {
    public function new() {
    }
    
    public function apply(target:Component):Void {
    }
    
    public function unapply(target:Component):Void {
    }
    
    private var _enabled:Bool = true;
    public var enabled(get, set):Bool;
    private function set_enabled(value:Bool):Bool {
        _enabled = value;
        return value;
    }
    private function get_enabled():Bool {
        return _enabled;
    }
}