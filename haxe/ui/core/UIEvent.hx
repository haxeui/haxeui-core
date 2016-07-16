package haxe.ui.core;

class UIEvent {
    public static inline var READY:String = "Ready";
    public static inline var RESIZE:String = "Resize";
    public static inline var CHANGE:String = "Change";

    public var type(default, default):String;
    public var target(default, default):Component;

    public function new(type:String) {
        this.type = type;
    }

    public function clone():UIEvent {
        var c:UIEvent = new UIEvent(this.type);
        c.type = this.type;
        c.target = this.target;
        return c;
    }
}
