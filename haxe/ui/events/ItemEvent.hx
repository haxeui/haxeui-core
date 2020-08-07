package haxe.ui.events;

import haxe.ui.core.Component;
import haxe.ui.events.UIEvent;

class ItemEvent extends UIEvent {
    public static inline var COMPONENT_EVENT:String = "itemComponentEvent";
    
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