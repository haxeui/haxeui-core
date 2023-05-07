package haxe.ui.constants;

enum abstract Priority(Int) from Int to Int {
    var LOWEST = -1000;
    var LOW = -100;
    var NORMAL = 0;
    var HIGH = 100;
    var HIGHEST = 1000;
}
