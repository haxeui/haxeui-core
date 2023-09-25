package haxe.ui.filters;

class Tint extends Filter {
    public static var DEFAULTS:Array<Any> = [0, 1];

    public var color:Int;
    public var amount:Float;

    public override function parse(filterDetails:Array<Any>) {
        var copy = Filter.applyDefaults(filterDetails, DEFAULTS);
        this.color = copy[0];
        this.amount = copy[1];
    }
}