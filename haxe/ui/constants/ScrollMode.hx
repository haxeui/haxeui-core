package haxe.ui.constants;

@:enum
abstract ScrollMode(String) from String to String {
    var NORMAL = "normal";
    var DRAG = "drag";
    var INERTIAL = "inertial";
}
