package haxe.ui.core;

import haxe.ui.util.Variant;

@:dox(hide) @:noCompletion
class DefaultBehaviour extends Behaviour {
    private var _value:Variant;
    
    public override function get():Variant {
        return _value;
    }
    
    public override function set(value:Variant) {
        if (value == _value) {
            return;
        }

        super.set(value);
    }
}