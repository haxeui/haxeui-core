package haxe.ui.filters;

class HueRotate extends Filter {
    public static var DEFAULTS:Array<Any> = [1];

    /**
        Applies rotation in degrees
    **/ 
    public var angleDegree:Float;

    public override function parse(filterDetails:Array<Any>) {
        var copy = Filter.applyDefaults(filterDetails, DEFAULTS);
        this.angleDegree = copy[0];
    }
}