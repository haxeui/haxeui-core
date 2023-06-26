package haxe.ui.filters;

class Outline extends Filter {
    public static var DEFAULTS:Array<Any> = [0, 1];

    public var color:Int;
    public var size:Int;

    public override function parse(filterDetails:Array<Any>) {
        var copy = Filter.applyDefaults(filterDetails, DEFAULTS);
        this.color = copy[0];
        this.size = copy[1];
    }
}