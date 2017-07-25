package haxe.ui.core;

class MouseEvent extends UIEvent {
    public static inline var MOUSE_MOVE:String = "mousemove";
    public static inline var MOUSE_OVER:String = "mouseover";
    public static inline var MOUSE_OUT:String = "mouseout";
    public static inline var MOUSE_DOWN:String = "mousedown";
    public static inline var MOUSE_UP:String = "mouseup";
    public static inline var MOUSE_WHEEL:String = "mousewheel";
    public static inline var CLICK:String = "click";

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