package haxe.ui.validation;

@:enum
abstract InvalidationFlags(String) from String to String {
    var ALL = "all";
    var DATA = "data";
    var DISPLAY = "display";
    var INDEX = "index";
    var LAYOUT = "layout";
    var MEASURE = "measure";
    var POSITION = "position";
    var SCROLL = "scroll";
    var STYLE = "style";
}
