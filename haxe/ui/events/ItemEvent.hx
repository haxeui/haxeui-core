package haxe.ui.events;

import haxe.ui.core.Component;

class ItemEvent extends UIEvent {
    public static final COMPONENT_EVENT:EventType<ItemEvent> = EventType.name("itemcomponentevent");
    public static final COMPONENT_CLICK_EVENT:EventType<ItemEvent> = EventType.name("itemcomponentclickevent");
    public static final COMPONENT_CHANGE_EVENT:EventType<ItemEvent> = EventType.name("itemcomponentchangeevent");

    public var source:Component = null;
    public var sourceEvent:UIEvent = null;
    public var itemIndex:Int = -1;

    public override function clone():UIEvent {
        var c:ItemEvent = new ItemEvent(this.type);
        c.source = this.source;
        c.sourceEvent = this.sourceEvent;
        c.itemIndex = this.itemIndex;
        c.type = this.type;
        c.bubble = this.bubble;
        c.target = this.target;
        c.data = this.data;
        c.canceled = this.canceled;
        postClone(c);
        return c;
    }
}