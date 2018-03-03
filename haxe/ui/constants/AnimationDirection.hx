package haxe.ui.constants;

@:enum
abstract AnimationDirection(String) from String to String {
    var NORMAL = "normal";
    var REVERSE = "reverse";
    var ALTERNATE = "alternate";
    var ALTERNATE_REVERSE = "alternate-reverse";
}
