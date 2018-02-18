package haxe.ui.core;

import haxe.ui.backend.EventBase;

class UIEvent extends EventBase {
    public static inline var READY:String = "ready";
    public static inline var RESIZE:String = "resize";
    public static inline var CHANGE:String = "change";
    public static inline var BEFORE_CHANGE:String = "beforeChange";
    public static inline var MOVE:String = "move";

    public var type(default, default):String;
    public var target(default, default):Component;
    public var data(default, default):Dynamic;

    public function new(type:String) {
        super();
        this.type = type;
    }

    public function clone():UIEvent {
        var c:UIEvent = new UIEvent(this.type);
        c.type = this.type;
        c.target = this.target;
        c.data = this.data;
        postClone(c);
        return c;
    }
}
