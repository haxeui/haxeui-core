package haxe.ui.events;

class FocusEvent extends UIEvent {
    public static inline var FOCUS_IN:String = "focusin";
    public static inline var FOCUS_OUT:String = "focusout";

    public function new(type:String) {
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