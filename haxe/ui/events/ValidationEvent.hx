package haxe.ui.events;

class ValidationEvent extends UIEvent {
    public static final START:EventType<ValidationEvent> = EventType.name("validationstart");
    public static final STOP:EventType<ValidationEvent> = EventType.name("validationstop");

    public function new(type:String) {
        super(type);
    }

    public override function clone():ValidationEvent {
        var c:ValidationEvent = new ValidationEvent(this.type);
        c.type = this.type;
        c.target = this.target;
        postClone(c);
        return c;
    }
}