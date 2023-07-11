package haxe.ui.events;

class AnimationEvent extends UIEvent {
    public static final LOADED:EventType<AnimationEvent> = EventType.name("animationloaded");
    public static final START:EventType<AnimationEvent> = EventType.name("animationstart");
    public static final END:EventType<AnimationEvent> = EventType.name("animationend");
    public static final FRAME:EventType<AnimationEvent> = EventType.name("animationframe");

    public var currentTime:Float;
    public var delta:Float;
    public var position:Float;
    
    public function new(type:EventType<AnimationEvent>) {
        super(type);
    }

    public override function clone():AnimationEvent {
        var c:AnimationEvent = new AnimationEvent(this.type);
        c.currentTime = this.currentTime;
        c.delta = this.delta;
        c.position = this.position;
        return c;
    }
}