package haxe.ui.behaviours;

import haxe.ui.util.Variant;

@:dox(hide) @:noCompletion
class DataBehaviour extends ValueBehaviour {
    private var _dataInvalid:Bool;

    public override function set(value:Variant) {
        if (value == get()) {
            return;
        }
        
        _value = value;
        invalidateData();
    }

    public function validate() {
        if (_dataInvalid) {
            _dataInvalid = false;
            validateData();
        }
    }

    private function invalidateData() {
        _dataInvalid = true;
        _component.invalidateComponentData();
    }
    
    private function validateData() {
    }
}