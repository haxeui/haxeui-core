package haxe.ui.core;

class ScrollEvent extends UIEvent {
    public static inline var CHANGE:String = "scrollchange";
    public static inline var START:String = "scrollstart";
    public static inline var STOP:String = "scrollstop";

    public function new(type:String) {
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