package haxe.ui.core;
import haxe.ui.util.Variant;

@:dox(hide) @:noCompletion
class ValueBehaviour extends Behaviour {
    private var _value:Variant;
    
    public function new(component:Component, defaultValue:Variant = null) {
        super(component);
        if (defaultValue != null) {
            _value = defaultValue;
        }
    }
    
    public override function get():Variant {
        return _value;
    }
    public override function set(value:Variant) {
        if (!value.isNull && !_value.isNull) {
            if (value.isFloat && _value.toFloat() == value.toFloat()) {
                return;
            }
            if (value.isInt && _value.toInt() == value.toInt()) {
                return;
            }
            if (value.isString && _value.toString() == value.toString()) {
                return;
            }
            if (value.isBool && _value.toBool() == value.toBool()) {
                return;
            }
        }
        _value = value;
        _component.invalidateData();
    }
}
