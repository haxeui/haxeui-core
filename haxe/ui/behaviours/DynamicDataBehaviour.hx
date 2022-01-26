package haxe.ui.behaviours;

class DynamicDataBehaviour extends DynamicBehaviour implements IValidatingBehaviour {
    private var _dataInvalid:Bool;

    public override function setDynamic(value:Dynamic) {
        if (value == getDynamic()) {
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