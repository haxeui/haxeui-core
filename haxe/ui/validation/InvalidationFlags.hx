package haxe.ui.validation;

@:enum
abstract InvalidationFlags(String) from String to String {
    var ALL = "all";
    var DATA = "data";
    var DISPLAY = "display";
    var LAYOUT = "layout";
    var POSITION = "position";
    var STYLE = "style";
}
