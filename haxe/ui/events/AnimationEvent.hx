package haxe.ui.events;

class AnimationEvent extends UIEvent {
    public static inline var START:String = "animationstart";
    public static inline var END:String = "animationend";
    public static inline var FRAME:String = "animationframe";

    public var currentTime:Float;
    public var delta:Float;
    public var position:Float;
    
    public function new(type:String) {
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