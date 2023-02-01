package haxe.ui.validators;

import haxe.ui.core.Component;

class Validator implements IValidator {
    public var invalidMessage:String;

    public var applyValid:Bool = true;
    public var applyInvalid:Bool = true;

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
            case TObject:
                valid = validateString(component.text);
            case _:
                trace("unsupported", Type.typeof(component.value), component.id, component.className, component.value);
        }

        if (valid == null) {
            onReset(component);
            return valid;
        }

        if (valid) {
            if (applyValid) {
                onValid(component);
            } else {
                onReset(component);
            }
        } else {
            if (applyInvalid) {
                onInvalid(component);
            } else {
                onReset(component);
            }
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

    public function setProperty(name:String, value:Any) {
        switch (name) {
            case "applyValid":
                applyValid = value;
            case "applyInvalid":
                applyInvalid = value;
        }
    }
}