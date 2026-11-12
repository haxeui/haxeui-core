package haxe.ui.events;

import haxe.ui.core.Component;

class DragEvent extends UIEvent {
    public static final DRAG_START:EventType<DragEvent> = EventType.name("dragstart");
    public static final DRAG:EventType<DragEvent> = EventType.name("drag");
    public static final DRAG_END:EventType<DragEvent> = EventType.name("dragend");

    /**
     * Drag and drop, dispatched on a drop target: a drag has come over it. Cancel the event to
     * refuse the drag; the target then gets no DROP and no hover style while it stays over it.
     */
    public static final DRAG_ENTER:EventType<DragEvent> = EventType.name("dragenter");
    /** Drag and drop, dispatched on a drop target: an accepted drag has left it. */
    public static final DRAG_LEAVE:EventType<DragEvent> = EventType.name("dragleave");
    /** Drag and drop, dispatched on a drop target: an accepted drag was released over it. */
    public static final DROP:EventType<DragEvent> = EventType.name("drop");

    public var left:Float = 0;
    public var top:Float = 0;

    /**
     * Drag and drop: the component being dragged. `data` is its DragOptions.dragData. On the
     * DRAG_END of a drag-and-drop, `relatedComponent` is the drop target it was dropped on, or
     * null when it was dropped somewhere else.
     */
    public var dragSource:Component = null;
    
    
    public override function clone():DragEvent {
        var c:DragEvent = new DragEvent(this.type);
        c.type = this.type;
        c.bubble = this.bubble;
        c.target = this.target;
        c.data = this.data;
        c.value = this.value;
        c.previousValue = this.previousValue;
        c.canceled = this.canceled;
        c.relatedEvent = this.relatedEvent;
        c.relatedComponent = this.relatedComponent;
        c.left = this.left;
        c.top = this.top;
        c.dragSource = this.dragSource;
        postClone(c);
        return c;
    }
    
    public override function copyFrom(c:UIEvent) {
        var d = cast(c, DragEvent);
        left = d.left;
        top = d.top;
        dragSource = d.dragSource;
    }
}