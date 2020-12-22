package haxe.ui.styles.animation.util;

class StringPropertyDetails<T> {
    public var propertyName:String;
    public var start:String;
    public var end:String;
    public var target:T;

    public var startInt:Int;
    public var changeInt:Int;
    public var pattern:String = null;

    public var isVariant:Bool = false;

    public function new (target:T, propertyName:String, start:String, end:String):Void {
        this.target = target;
        this.propertyName = propertyName;
        this.start = start;
        this.end = end;
    }
}