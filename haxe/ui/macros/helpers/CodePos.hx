package haxe.ui.macros.helpers;

@:enum
abstract CodePos(Int) from Int to Int {
    var Start = -1;
    var End = 0xFFFFFF;
}