package haxe.ui.styles.animation.util;

import haxe.ui.util.Color;

class ColorPropertyDetails<T> {
    public var changeR:Int;
    public var changeG:Int;
    public var changeB:Int;
    public var changeA:Int;
    public var propertyName:String;
    public var start:Color;
    public var target:T;

    public function new (target:T, propertyName:String, start:Color, changeR:Int, changeG:Int, changeB:Int, changeA:Int):Void {
        this.target = target;
        this.propertyName = propertyName;
        this.start = start;
        this.changeR = changeR;
        this.changeG = changeG;
        this.changeB = changeB;
        this.changeA = changeA;
    }
}