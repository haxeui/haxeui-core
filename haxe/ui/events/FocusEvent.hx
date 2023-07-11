package haxe.ui.events;

class FocusEvent extends UIEvent {
    public static final FOCUS_IN:EventType<FocusEvent> = EventType.name("focusin");
    public static final FOCUS_OUT:EventType<FocusEvent> = EventType.name("focusout");

    public function new(type:EventType<FocusEvent>) {
        super(type);
    }

    public override function clone():FocusEvent {
        var c:FocusEvent = new FocusEvent(this.type);
        c.type = this.type;
        c.target = this.target;
        postClone(c);
        return c;
    }
}