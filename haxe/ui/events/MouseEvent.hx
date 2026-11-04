package haxe.ui.events;

class MouseEvent extends UIEvent {
    public static final MOUSE_MOVE:EventType<MouseEvent> = EventType.name("mousemove");
    public static final MOUSE_OVER:EventType<MouseEvent> = EventType.name("mouseover");
    public static final MOUSE_OUT:EventType<MouseEvent> = EventType.name("mouseout");
    public static final MOUSE_DOWN:EventType<MouseEvent> = EventType.name("mousedown");
    public static final MOUSE_UP:EventType<MouseEvent> = EventType.name("mouseup");
    public static final MOUSE_WHEEL:EventType<MouseEvent> = EventType.name("mousewheel");
    public static final CLICK:EventType<MouseEvent> = EventType.name("click");
    public static final DBL_CLICK:EventType<MouseEvent> = EventType.name("doubleclick");
    public static final RIGHT_CLICK:EventType<MouseEvent> = EventType.name("rightclick");
    public static final RIGHT_MOUSE_DOWN:EventType<MouseEvent> = EventType.name("rightmousedown");
    public static final RIGHT_MOUSE_UP:EventType<MouseEvent> = EventType.name("rightmouseup");
    public static final MIDDLE_CLICK:EventType<MouseEvent> = EventType.name("middleclick");
    public static final MIDDLE_MOUSE_DOWN:EventType<MouseEvent> = EventType.name("middlemousedown");
    public static final MIDDLE_MOUSE_UP:EventType<MouseEvent> = EventType.name("middlemouseup");
    /**
        A touch held still on the component (a long press), where the backend sends one. The component listening takes
        the press: no click follows, and a scroll view under it lets go.
    **/
    public static final LONG_PRESS:EventType<MouseEvent> = EventType.name("longpress");

    public var screenX:Float;
    public var screenY:Float;
    public var buttonDown:Bool;
    public var delta:Float;
    /** A sideways wheel or touchpad scroll, as `delta` is up and down: positive to the right. **/
    public var deltaX:Float = 0;
    public var touchEvent:Bool;
    /**
        When a touch happened, in seconds, where the backend knows: it only means something against another touch's,
        and it's truer than the frame that shows the touch, which comes up to a refresh later. 0 where there's none.
    **/
    public var touchTime:Float = 0;
    public var ctrlKey:Bool;
    public var shiftKey:Bool;

    public function new(type:EventType<MouseEvent>) {
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
        c.data = this.data;
        c.type = this.type;
        c.target = this.target;
        c.screenX = this.screenX;
        c.screenY = this.screenY;
        c.buttonDown = this.buttonDown;
        c.delta = this.delta;
        c.deltaX = this.deltaX;
        c.touchEvent = this.touchEvent;
        c.touchTime = this.touchTime;
        c.ctrlKey = this.ctrlKey;
        c.shiftKey = this.shiftKey;
        postClone(c);
        return c;
    }
}