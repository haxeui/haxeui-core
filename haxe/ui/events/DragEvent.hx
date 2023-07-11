package haxe.ui.events;

class DragEvent extends UIEvent {
    public static final DRAG_START:EventType<DragEvent> = EventType.name("dragstart");
    public static final DRAG:EventType<DragEvent> = EventType.name("drag");
    public static final DRAG_END:EventType<DragEvent> = EventType.name("dragend");
    
    public var left:Float = 0;
    public var top:Float = 0;
    
    
    public override function clone():DragEvent {
        var c:DragEvent = new DragEvent(this.type);
        c.type = this.type;
        c.bubble = this.bubble;
        c.target = this.target;
        c.data = this.data;
        c.canceled = this.canceled;
        c.left = this.left;
        c.top = this.top;
        postClone(c);
        return c;
    }
    
    public override function copyFrom(c:UIEvent) {
        var d = cast(c, DragEvent);
        left = d.left;
        top = d.top;
    }
}