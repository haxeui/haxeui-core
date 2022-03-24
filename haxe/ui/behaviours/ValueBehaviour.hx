package haxe.ui.behaviours;

import haxe.ui.util.Variant;

@:dox(hide) @:noCompletion
class ValueBehaviour extends Behaviour {
    private var _previousValue:Variant;
    private var _value:Variant;

    public override function get():Variant {
        return _value;
    }

    public override function set(value:Variant) {
        if (value == _value) {
            return;
        }

        _previousValue = _value;
        _value = value;
    }
}
