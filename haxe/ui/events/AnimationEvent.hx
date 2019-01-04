package haxe.ui.events;

class AnimationEvent extends UIEvent {
    public static inline var START:String = "animationstart";
    public static inline var END:String = "animationend";

    public function new(type:String) {
        super(type);
    }

    public override function clone():AnimationEvent {
        var c:AnimationEvent = new AnimationEvent(this.type);
        return c;
    }
}