package haxe.ui.events;

import haxe.ui.backend.EventImpl;
import haxe.ui.core.Component;
import haxe.ui.util.Variant;

@:build(haxe.ui.macros.Macros.buildEvent())
@:autoBuild(haxe.ui.macros.Macros.buildEvent())
class UIEvent extends EventImpl {
    public static final READY:EventType<UIEvent> = EventType.name("ready");
    public static final DESTROY:EventType<UIEvent> = EventType.name("destroy");    
    public static final RESIZE:EventType<UIEvent> = EventType.name("resize");
    public static final CHANGE:EventType<UIEvent> = EventType.name("change");
    public static final BEFORE_CHANGE:EventType<UIEvent> = EventType.name("beforechange");
    public static final MOVE:EventType<UIEvent> = EventType.name("move");
    public static final INITIALIZE:EventType<UIEvent> = EventType.name("initialize");

    public static final SUBMIT_START:EventType<UIEvent> = EventType.name("submitstart");
    public static final SUBMIT:EventType<UIEvent> = EventType.name("submit");

    public static final RENDERER_CREATED:EventType<UIEvent> = EventType.name("renderercreated");
    public static final RENDERER_DESTROYED:EventType<UIEvent> = EventType.name("rendererdestroyed");

    public static final HIDDEN:EventType<UIEvent> = EventType.name("hidden");
    public static final SHOWN:EventType<UIEvent> = EventType.name("shown");

    public static final ENABLED:EventType<UIEvent> = EventType.name("enabled");
    public static final DISABLED:EventType<UIEvent> = EventType.name("disabled");

    public static final BEFORE_CLOSE:EventType<UIEvent> = EventType.name("beforeclose");
    public static final CLOSE:EventType<UIEvent> = EventType.name("close");

    public static final PROPERTY_CHANGE:EventType<UIEvent> = EventType.name("propertychange");

    public static final COMPONENT_ADDED:EventType<UIEvent> = EventType.name("componentadded");
    public static final COMPONENT_REMOVED:EventType<UIEvent> = EventType.name("componentremoved");

    public static final COMPONENT_ADDED_TO_PARENT:EventType<UIEvent> = EventType.name("componentaddedtoparent");
    public static final COMPONENT_REMOVED_FROM_PARENT:EventType<UIEvent> = EventType.name("componentremovedfromparent");

    public var bubble(default, default):Bool;
    public var type(default, default):String;
    public var target(default, default):Component;
    public var data(default, default):Dynamic;
    public var canceled(default, default):Bool;
    // an event might have a related event, for example, a change event might
    // contain a related event as to where the event came from (mouse, keyboard, action)
    public var relatedEvent(default, default):UIEvent = null;
    public var relatedComponent(default, default):Component = null;

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

    @:noCompletion public function clone():UIEvent {
        var c:UIEvent = new UIEvent(this.type);
        c.type = this.type;
        c.bubble = this.bubble;
        c.target = this.target;
        c.data = this.data;
        c.value = this.value;
        c.previousValue = this.previousValue;
        c.canceled = this.canceled;
        c.relatedEvent = this.relatedEvent;
        c.relatedComponent = this.relatedComponent;
        postClone(c);
        return c;
    }
    
    @:noCompletion public function copyFrom(c:UIEvent) {
        
    }
}
