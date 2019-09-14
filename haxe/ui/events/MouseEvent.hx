package haxe.ui.events;

class MouseEvent extends UIEvent {
    public static inline var MOUSE_MOVE:String = "mousemove";
    public static inline var MOUSE_OVER:String = "mouseover";
    public static inline var MOUSE_OUT:String = "mouseout";
    public static inline var MOUSE_DOWN:String = "mousedown";
    public static inline var MOUSE_UP:String = "mouseup";
    public static inline var MOUSE_WHEEL:String = "mousewheel";
    public static inline var CLICK:String = "click";
    public static inline var RIGHT_CLICK:String = "rightclick";
    public static inline var RIGHT_MOUSE_DOWN:String = "rightmousedown";
    public static inline var RIGHT_MOUSE_UP:String = "rightmouseup";

    public var screenX:Float;
    public var screenY:Float;
    public var buttonDown:Bool;
    public var delta:Float;
    public var touchEvent:Bool;
    public var ctrlKey:Bool;
    public var shiftKey:Bool;

    public function new(type:String) {
        super(type);
    }

    public var localX(get, null):Null<Float>;
    private function get_localX():Null<Float> {
        if (target == null) {
            return null;
        }
        
        return ((screenX * Toolkit.scaleX) - target.screenLeft) / Toolkit.scaleX;
    }
    
    public var localY(get, null):Null<Float>;
    private function get_localY():Null<Float> {
        if (target == null) {
            return null;
        }
        
        return ((screenY * Toolkit.scaleY) - target.screenTop) / Toolkit.scaleY;
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
        c.ctrlKey = this.ctrlKey;
        c.shiftKey = this.shiftKey;
        postClone(c);
        return c;
    }
}