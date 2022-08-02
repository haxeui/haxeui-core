package haxe.ui.events;

import haxe.ui.backend.EventImpl;
import haxe.ui.core.Component;
import haxe.ui.util.Variant;

@:build(haxe.ui.macros.Macros.buildEvent())
@:autoBuild(haxe.ui.macros.Macros.buildEvent())
class UIEvent extends EventImpl {
    public static inline var READY:String = "ready";
    public static inline var DESTROY:String = "destroy";    
    public static inline var RESIZE:String = "resize";
    public static inline var CHANGE:String = "change";
    public static inline var BEFORE_CHANGE:String = "beforechange";
    public static inline var MOVE:String = "move";
    public static inline var INITIALIZE:String = "initialize";

    public static inline var RENDERER_CREATED:String = "renderercreated";
    public static inline var RENDERER_DESTROYED:String = "rendererdestroyed";

    public static inline var HIDDEN:String = "hidden";
    public static inline var SHOWN:String = "shown";

    public static inline var ENABLED:String = "enabled";
    public static inline var DISABLED:String = "disabled";

    public static inline var BEFORE_CLOSE:String = "beforeclose";
    public static inline var CLOSE:String = "close";

    public static inline var PROPERTY_CHANGE:String = "propertychange";

    public static inline var COMPONENT_ADDED:String = "componentadded";
    public static inline var COMPONENT_REMOVED:String = "componentremoved";

    public var bubble(default, default):Bool;
    public var type(default, default):String;
    public var target(default, default):Component;
    public var data(default, default):Dynamic;
    public var canceled(default, default):Bool;
    // an event might have a related event, for example, a change event might
    // contain a related event as to where the event came from (mouse, keyboard, action)
    public var relatedEvent(default, default):UIEvent = null;

    public var value:Variant;
    public var previousValue:Variant;
    
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
        c.value = this.value;
        c.previousValue = this.previousValue;
        c.canceled = this.canceled;
        c.relatedEvent = this.relatedEvent;
        postClone(c);
        return c;
    }
    
    public function copyFrom(c:UIEvent) {
        
    }
}
