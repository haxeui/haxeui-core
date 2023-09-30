package haxe.ui.filters;

class Saturate extends Filter {
    public static var DEFAULTS:Array<Any> = [1];

    /**
        0 makes unsaturated, 1  makes no changes, over 1 increases saturation
    **/ 
    public var multiplier:Float;

    public override function parse(filterDetails:Array<Any>) {
        var copy = Filter.applyDefaults(filterDetails, DEFAULTS);
        this.multiplier = copy[0];

        if (this.multiplier < 0) {
            this.multiplier = 0;
        }
    }
}