package haxe.ui.core;

import haxe.ui.core.Behaviour;
import haxe.ui.util.Variant;

class DataBehaviour extends Behaviour {
    private var _value:Variant;
    
    public override function get():Variant {
        return _value;
    }
    
    public override function set(value:Variant) {
        if (value == get()) {
            return;
        }
        
        _value = value;
        _component.invalidateData();
    }
    
    public function validateData() {
    }
}