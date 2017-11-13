package haxe.ui.core;

class KeyboardEvent extends UIEvent {
    public static inline var KEY_TAB:Int = 9;

    public static inline var KEY_DOWN:String = "keydown";
    public static inline var KEY_UP:String = "keyup";

    public var keyCode:Int;
    public var shiftKey:Bool;

    public function new(type:String) {
        super(type);
    }

    public override function clone():KeyboardEvent {
        var c:KeyboardEvent = new KeyboardEvent(this.type);
        c.type = this.type;
        c.target = this.target;
        c.keyCode = this.keyCode;
        c.shiftKey = this.shiftKey;
        return c;
    }
}