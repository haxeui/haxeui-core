package haxe.ui.filters;

class DropShadow extends Filter {
    private static var DEFAULTS:Array<Any> = [4, 45, 0, 1, 4, 4, 1, 1, false, false, false];

    public var distance:Float;
    public var angle:Float;
    public var color:Int;
    public var alpha:Float;
    public var blurX:Float;
    public var blurY:Float;
    public var strength:Float;
    public var quality:Int;
    public var inner:Bool;

    public override function parse(filterDetails:Array<Any>) {
        var copy = Filter.applyDefaults(filterDetails, DEFAULTS);
        this.distance = copy[0];
        this.angle = copy[1];
        this.color = copy[2];
        this.alpha = copy[3];
        this.blurX = copy[4];
        this.blurY = copy[5];
        this.strength = copy[6];
        this.quality = copy[7];
        this.inner = copy[8];
    }
}