package haxe.ui.events;

class KeyboardEvent extends UIEvent {
    public static final KEY_DOWN:EventType<KeyboardEvent> = EventType.name("keydown");
    public static final KEY_PRESS:EventType<KeyboardEvent> = EventType.name("keypress");
    public static final KEY_UP:EventType<KeyboardEvent> = EventType.name("keyup");

    public var keyCode:Int;
    public var altKey:Bool;
    public var ctrlKey:Bool;
    public var shiftKey:Bool;

    public function new(type:EventType<KeyboardEvent>) {
        super(type);
    }

    public override function clone():KeyboardEvent {
        var c:KeyboardEvent = new KeyboardEvent(this.type);
        c.type = this.type;
        c.target = this.target;
        c.keyCode = this.keyCode;
        c.altKey = this.altKey;
        c.ctrlKey = this.ctrlKey;
        c.shiftKey = this.shiftKey;
        postClone(c);
        return c;
    }
}
