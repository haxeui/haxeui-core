package haxe.ui.core;

import haxe.ui.backend.EventBase;

class UIEvent extends EventBase {
    public static inline var READY:String = "Ready";
    public static inline var RESIZE:String = "Resize";
    public static inline var CHANGE:String = "Change";
    public static inline var MOVE:String = "Move";

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
