package haxe.ui.validators;

import haxe.ui.core.Component;

class Validator implements IValidator {
    public var invalidMessage:String;

    public function new() {
    }

    public function setup(component:Component) {
    }

    public function validate(component:Component):Null<Bool> {
        return validateInternal(component);
    }

    private function validateInternal(component:Component):Null<Bool> {
        var valid:Null<Bool> = null;
        switch (Type.typeof(component.value)) {
            case TClass(String):
                var stringValue:String = null;
                if (component.value != null) {
                    stringValue = Std.string(component.value);
                }
                valid = validateString(stringValue);
            case TNull:
                valid = validateString(null);
            case _:
                trace("unsupported", Type.typeof(component.value), component.id, component.className);
        }

        if (valid == null) {
            onReset(component);
            return valid;
        }

        if (valid) {
            onValid(component);
        } else {
            onInvalid(component);
        }

        return valid;

    }

    private function onReset(component:Component) {
        component.removeClasses(["valid", "invalid"]);
    }

    private function onValid(component:Component) {
        component.swapClass("valid", "invalid");
    }

    private function onInvalid(component:Component) {
        component.swapClass("invalid", "valid");
    }

    private function validateString(s:String):Null<Bool> {
        return null;
    }
}