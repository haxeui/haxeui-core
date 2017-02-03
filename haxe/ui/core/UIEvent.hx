package haxe.ui.core;

import haxe.ui.backend.EventBase;

class UIEvent extends EventBase {
    public static inline var READY:String = "Ready";
    public static inline var RESIZE:String = "Resize";
    public static inline var CHANGE:String = "Change";
    public static inline var MOVE:String = "Move";

    public var bubble(default, default):Bool;
    public var type(default, default):String;
    public var target(default, default):Component;

    public var canceled(default, default):Bool;

    public function new(type:String, bubble:Bool=false) {
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
        postClone(c);
        return c;
    }
}
