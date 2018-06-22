package haxe.ui.core;

import haxe.ui.backend.EventBase;

class UIEvent extends EventBase {
    public static inline var READY:String = "ready";
    public static inline var RESIZE:String = "resize";
    public static inline var CHANGE:String = "change";
    public static inline var BEFORE_CHANGE:String = "beforeChange";
    public static inline var MOVE:String = "move";

    public var bubble(default, default):Bool;
    public var type(default, default):String;
    public var target(default, default):Component;
    public var data(default, default):Dynamic;

    public var canceled(default, default):Bool;

    public function new(type:String, bubble:Bool = false) {
        super();
        this.type = type;
        this.bubble = bubble;
        this.canceled = false;
    }

    public override function cancel() {
        super.cancel();

        canceled = true;
    }

    public function clone():UIEvent {
        var c:UIEvent = new UIEvent(this.type);
        c.bubble = this.bubble;
        c.canceled = this.canceled;
        c.type = this.type;
        c.target = this.target;
        c.data = this.data;
        postClone(c);
        return c;
    }
}
