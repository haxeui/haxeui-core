package haxe.ui.core;

class ValidationEvent extends UIEvent {
    public static inline var START:String = "ValidationStart";
    public static inline var STOP:String = "ValidationStop";

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