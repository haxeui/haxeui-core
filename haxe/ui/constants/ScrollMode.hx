package haxe.ui.constants;

import haxe.ui.util.Variant;

enum abstract ScrollMode(String) to String {
	var DEFAULT = "default";
	var NORMAL = "normal";
	var DRAG = "drag";
	var INERTIAL = "inertial";
	var HYBRID = "hybrid";
	var NATIVE = "native";

	@:from public static function fromString(s:String):ScrollMode {
		return switch (s.toLowerCase()) {
			case "default":     DEFAULT;
			case "normal":      NORMAL;
			case "drag":        DRAG;
			case "inertial":    INERTIAL;
			case "hybrid":      HYBRID;
			case "native":      NATIVE;
			case _: throw "invalid ScrollMode enum value '" + s + "'";
		}
	}

    @:from public static function fromVariant(v:Variant):ScrollMode {
        if (v == null || v.isNull) {
            return null;
        }
        return fromString(v.toString());
    }
}