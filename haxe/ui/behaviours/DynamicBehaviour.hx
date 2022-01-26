package haxe.ui.behaviours;
import haxe.ui.util.Variant;

@:dox(hide) @:noCompletion
class DynamicBehaviour extends Behaviour {
    private var _value:Dynamic;

    public override function getDynamic():Dynamic {
        return _value;
    }

    public override function setDynamic(value:Dynamic) {
        if (value == _value) {
            return;
        }

        _value = value;
    }
    
    public override function set(value:Variant) {
        setDynamic(Variant.toDynamic(value));
    }
}