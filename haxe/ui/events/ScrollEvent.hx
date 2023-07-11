package haxe.ui.events;

class ScrollEvent extends UIEvent {
    public static final CHANGE:EventType<ScrollEvent> = EventType.name("scrollchange");
    public static final START:EventType<ScrollEvent> = EventType.name("scrollstart");
    public static final STOP:EventType<ScrollEvent> = EventType.name("scrollstop");
    public static final SCROLL:EventType<ScrollEvent> = EventType.name("scrollscroll");

    public function new(type:EventType<ScrollEvent>) {
        super(type);
    }

    public override function clone():ScrollEvent {
        var c:ScrollEvent = new ScrollEvent(this.type);
        c.type = this.type;
        c.target = this.target;
        postClone(c);
        return c;
    }
}