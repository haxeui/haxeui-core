package haxe.ui.validators;

import haxe.ui.core.Component;

class PatternValidator extends Validator {
    public var pattern:EReg = null;

    private override function validateString(s:String):Null<Bool> {
        if (pattern == null) {
            return true;
        }

        var valid:Null<Bool> = null;
        if (s != null && s.length > 0) {
            valid = pattern.match(s);
        }

        return valid;
    }
}