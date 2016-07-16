package haxe.ui.util;

class Size {
    public var width(default, default):Float;
    public var height(default, default):Float;

    public function new(width:Float = 0, height:Float = 0) {
        this.width = width;
        this.height = height;
    }

    public function toString():String {
        return '[${width}x${height}]';
    }
}