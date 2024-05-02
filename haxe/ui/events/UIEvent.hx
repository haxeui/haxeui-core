package haxe.ui.events;

import haxe.ui.backend.EventImpl;
import haxe.ui.core.Component;
import haxe.ui.util.Variant;

@:build(haxe.ui.macros.Macros.buildEvent())
@:autoBuild(haxe.ui.macros.Macros.buildEvent())
class UIEvent extends EventImpl {

    /** READY is dispatched when component is ready **/ 
    public static final READY:EventType<UIEvent> = EventType.name("ready");
    /** DESTROY is dispatched when component is destroyed **/
    public static final DESTROY:EventType<UIEvent> = EventType.name("destroy");   
    /** RESIZE is dispatched when component is resized **/ 
    public static final RESIZE:EventType<UIEvent> = EventType.name("resize");
    /** CHANGE is dispatched when component's value has changed **/ 
    public static final CHANGE:EventType<UIEvent> = EventType.name("change");

    /** BEFORE_CHANGE is dispatched by tabs before a selection change**/
    public static final BEFORE_CHANGE:EventType<UIEvent> = EventType.name("beforechange");
    /** MOVE is dispatched when component has changed position **/
    public static final MOVE:EventType<UIEvent> = EventType.name("move");
    /** INITIALIZE is dispatched only once at first invalidation **/
    public static final INITIALIZE:EventType<UIEvent> = EventType.name("initialize");

    /** SUBMIT_START is dispatched by the Form container when user is submitting before validation of user inputted data **/
    public static final SUBMIT_START:EventType<UIEvent> = EventType.name("submitstart");
    /** SUBMIT is dispatched by the Textfield when user has typed ENTER key**/
    public static final SUBMIT:EventType<UIEvent> = EventType.name("submit");
 
    /** RENDERER_CREATED is dispatched by table and list views when item renderer is created, the data property of the event is the item **/
    public static final RENDERER_CREATED:EventType<UIEvent> = EventType.name("renderercreated");
    /** RENDERER_DESTROYED is dispatched by table and list views when item renderer is destroyed, the data property of the event is the item **/
    public static final RENDERER_DESTROYED:EventType<UIEvent> = EventType.name("rendererdestroyed");

    /** HIDDEN is dispatched when component is hidden **/
    public static final HIDDEN:EventType<UIEvent> = EventType.name("hidden");
    /** SHOWN is dispatched when component is shown **/
    public static final SHOWN:EventType<UIEvent> = EventType.name("shown");

    /** ENABLED is dispatched when component is enabled **/
    public static final ENABLED:EventType<UIEvent> = EventType.name("enabled");
    /** DISABLED is dispatched when component is disabled **/
    public static final DISABLED:EventType<UIEvent> = EventType.name("disabled");

    /** OPEN is dispatched by certain components when opened **/
    public static final OPEN:EventType<UIEvent> = EventType.name("open");

    /** BEFORE_CLOSE is dispatched by tab before closing **/
    public static final BEFORE_CLOSE:EventType<UIEvent> = EventType.name("beforeclose");
    /** CLOSE is dispatched by certain components when closed **/
    public static final CLOSE:EventType<UIEvent> = EventType.name("close");

    /** PROPERTY_CHANGE is dispatched by dropdowns, lists, etc where a specific property has changed usually selected item **/
    public static final PROPERTY_CHANGE:EventType<UIEvent> = EventType.name("propertychange");

    /** COMPONENT_CREATED is dispatched when a child component is added **/
    public static final COMPONENT_CREATED:EventType<UIEvent> = EventType.name("componentcreated");

    /** COMPONENT_ADDED is dispatched when a child component is added **/
    public static final COMPONENT_ADDED:EventType<UIEvent> = EventType.name("componentadded");
    /** COMPONENT_REMOVED is dispatched when a child component is removed **/
    public static final COMPONENT_REMOVED:EventType<UIEvent> = EventType.name("componentremoved");

    /** COMPONENT_ADDED_TO_PARENT is dispatched when the component is added to the parent **/
    public static final COMPONENT_ADDED_TO_PARENT:EventType<UIEvent> = EventType.name("componentaddedtoparent");
    /** COMPONENT_REMOVED_FROM_PARENT is dispatched when the component is removed from the parent **/
    public static final COMPONENT_REMOVED_FROM_PARENT:EventType<UIEvent> = EventType.name("componentremovedfromparent");


    /** Whether event will be dispatched to parent component **/
    public var bubble(default, default):Bool;
    /** Type of the event : `ready`, `shown` etc **/
    public var type(default, default):String;
    /** First component the event was dispatched to **/
    public var target(default, default):Component;
    /** Usually data that accompanies a property changed **/
    public var data(default, default):Dynamic;
    /** Whether the event was canceled. If canceled, it won't be dispatched to parent.
    Some events effects can be avoided if canceled **/
    public var canceled(default, default):Bool;

    /** An event might have a related event, for example, a change event might
    contain a related event as to where the event came from (mouse, keyboard, action) **/
    public var relatedEvent(default, default):UIEvent = null;
    /** An event might have relatedComponent which is different to the target. 
    For example, ADDED_COMPONENT will have the new child component as a related component **/
    public var relatedComponent(default, default):Component = null;

    /** Sometimes, you can access the new value of the component in a CHANGE event **/
    public var value:Variant;
    /** Sometimes, you can access the previous value of the component in a CHANGE event **/
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
