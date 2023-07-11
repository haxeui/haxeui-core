package haxe.ui.events;

import haxe.ui.constants.SortDirection;

class SortEvent extends UIEvent {
    public static final SORT_CHANGED:EventType<SortEvent> = EventType.name("sortchanged");
    
    public var direction:SortDirection;
    
    public override function clone():SortEvent {
        var c:SortEvent = new SortEvent(this.type);
        c.type = this.type;
        c.bubble = this.bubble;
        c.target = this.target;
        c.data = this.data;
        c.canceled = this.canceled;
        c.direction = this.direction;
        postClone(c);
        return c;
    }
}