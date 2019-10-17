package haxe.ui.events;

import haxe.ui.backend.EventImpl;
import haxe.ui.core.Component;

class UIEvent extends EventImpl {
    public static inline var READY:String = "ready";
    public static inline var RESIZE:String = "resize";
    public static inline var CHANGE:String = "change";
    public static inline var BEFORE_CHANGE:String = "beforeChange";
    public static inline var MOVE:String = "move";
    public static inline var INITIALIZE:String = "initialize";

    public static inline var RENDERER_CREATED:String = "rendererCreated";
    public static inline var RENDERER_DESTROYED:String = "rendererDestroyed";

    public static inline var HIDDEN:String = "hidden";
    public static inline var SHOWN:String = "shown";
    
    public static inline var ENABLED:String = "enabled";
    public static inline var DISABLED:String = "disabled";

    public static inline var BEFORE_CLOSE:String = "beforeClose";
    public static inline var CLOSE:String = "close";
    
    public var bubble(default, default):Bool; 
    public var type(default, default):String;
    public var target(default, default):Component;
    public var data(default, default):Dynamic;
    public var canceled(default, default):Bool; 

    public function new(type:String, bubble:Null<Bool> = false, data:Dynamic = null) {
        this.type = type;
        this.bubble = bubble; 
        this.data = data;
        this.canceled = false; 
    }

    public override function cancel() {
        super.cancel(); 
        canceled = true; 
    }
    
    public function clone():UIEvent {
        var c:UIEvent = new UIEvent(this.type);
        c.type = this.type;
        c.bubble = this.bubble; 
        c.target = this.target;
        c.data = this.data;
        c.canceled = this.canceled;
        postClone(c);
        return c;
    }
}
