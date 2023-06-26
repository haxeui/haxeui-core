package haxe.ui.filters;

class BoxShadow extends Filter {
    private static var DEFAULTS:Array<Any> = [2, 2, 0, .1, 1, 0, false];

    public var offsetX:Float;
    public var offsetY:Float;
    public var color:Int;
    public var alpha:Float;
    public var blurRadius:Float;
    public var spreadRadius:Float;
    public var inset:Bool;

    public override function parse(filterDetails:Array<Any>) {
        var copy = Filter.applyDefaults(filterDetails, DEFAULTS);
        this.offsetX = copy[0];
        this.offsetY = copy[1];
        this.color = copy[2];
        this.alpha = copy[3];
        this.blurRadius = copy[4];
        this.spreadRadius = copy[5];
        this.inset = copy[6];
    }
}