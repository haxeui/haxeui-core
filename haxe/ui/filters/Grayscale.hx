package haxe.ui.filters;

class Grayscale extends Filter {
    public static var DEFAULTS:Array<Any> = [100];

    public var amount:Float;

    public override function parse(filterDetails:Array<Any>) {
        var copy = Filter.applyDefaults(filterDetails, DEFAULTS);
        this.amount = copy[0];
    }
}