package haxe.ui.behaviours;

import haxe.ui.util.Variant;

@:dox(hide) @:noCompletion
class InvalidatingBehaviour extends ValueBehaviour {
    public override function get():Variant {
        return _value;
    }
    
    public override function set(value:Variant) {
        if (value == _value) {
            return;
        }

        super.set(value);
        _component.invalidateComponentLayout();
    }
}
