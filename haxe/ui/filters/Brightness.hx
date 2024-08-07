package haxe.ui.filters;

class Brightness extends Filter {
    public static var DEFAULTS:Array<Any> = [1];
    
    /**
        0 is black, 1 is has no effect, over 1 it brightens the image.
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