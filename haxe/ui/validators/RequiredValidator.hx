package haxe.ui.validators;

import haxe.ui.core.Component;

class RequiredValidator extends Validator {
    public function new() {
        super();
        invalidMessage = "Field is required";
        invalidStyleName = "required-value";
    }

    public override function setup(component:Component) {
        component.addClass("required");
    }

    private override function validateString(s:String):Null<Bool> {
        var valid:Null<Bool> = null;

        if (s == null) {
            valid = false;
        } else {
            valid = (s.length > 0);
        }

        return valid;
    }

    private override function onValid(component:Component) {
        component.removeClass(invalidStyleName);
    }

    private override function onInvalid(component:Component) {
        component.addClass(invalidStyleName);
    }
}