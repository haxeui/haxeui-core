package haxe.ui.core;

class MouseEvent extends UIEvent {
    public static inline var MOUSE_MOVE:String = "MouseMove";
    public static inline var MOUSE_OVER:String = "MouseOver";
    public static inline var MOUSE_OUT:String = "MouseOut";
    public static inline var MOUSE_DOWN:String = "MouseDown";
    public static inline var MOUSE_UP:String = "MouseUp";
    public static inline var MOUSE_WHEEL:String = "MouseWheel";
    public static inline var CLICK:String = "Click";

    public var screenX:Float;
    public var screenY:Float;
    public var buttonDown:Bool;
    public var delta:Float;
    public var touchEvent:Bool;
    
    public function new(type:String) {
        super(type);
    }

    public override function clone():MouseEvent {
        var c:MouseEvent = new MouseEvent(this.type);
        c.type = this.type;
        c.target = this.target;
        c.screenX = this.screenX;
        c.screenY = this.screenY;
        c.buttonDown = this.buttonDown;
        c.delta = this.delta;
        c.touchEvent = this.touchEvent;
        postClone(c);
        return c;
    }
}