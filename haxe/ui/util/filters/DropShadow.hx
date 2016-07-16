package haxe.ui.util.filters;

class DropShadow extends Filter {
    public var distance:Float;
    public var angle:Float;
    public var color:Int;
    public var alpha:Float;
    public var blurX:Float;
    public var blurY:Float;
    public var strength:Float;
    public var quality:Int;
    public var inner:Bool;

    public function new() {
        super();
    }
}