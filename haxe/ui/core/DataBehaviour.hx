package haxe.ui.core;

import haxe.ui.core.Behaviour;
import haxe.ui.util.Variant;

class DataBehaviour extends Behaviour {
    private var _value:Variant;
    private var _dataInvalid:Bool;
    
    public override function get():Variant {
        return _value;
    }
    
    public override function set(value:Variant) {
        if (value == get()) {
            return;
        }
        
        _value = value;
        _dataInvalid = true;
        _component.invalidateComponentData();
    }

    public function validate() {
        if (_dataInvalid) {
            _dataInvalid = false;
            validateData();
        }
    }
    
    private function validateData() {
    }
}