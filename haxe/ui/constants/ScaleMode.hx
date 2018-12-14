package haxe.ui.constants;

@:enum
abstract ScaleMode(String) from String to String {
    var NONE = "none";
    var FILL = "fill";
    var FIT_INSIDE = "fit-inside";
    var FIT_OUTSIDE = "fit-outside";
    var FIT_WIDTH = "fit-width";
    var FIT_HEIGHT = "fit-height";
}
