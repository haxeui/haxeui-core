package haxe.ui.constants;

@:enum
abstract ScaleMode(String) from String to String {
    var NONE = "none";
    var FILL = "fill";
    var FIT_INSIDE = "fitinside";
    var FIT_OUTSIDE = "fitoutside";
    var FIT_WIDTH = "fitwidth";
    var FIT_HEIGHT = "fitheight";
}
