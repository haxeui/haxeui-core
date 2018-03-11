package haxe.ui.styles.animation.util;

class PropertyDetails<T> {
    public var change:Float;
    public var propertyName:String;
    public var start:Float;
    public var target:T;

    public function new (target:T, propertyName:String, start:Float, change:Float):Void {
        this.target = target;
        this.propertyName = propertyName;
        this.start = start;
        this.change = change;
    }
}