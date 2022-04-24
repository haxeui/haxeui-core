package haxe.ui.events;
import haxe.ui.actions.ActionType;

class ActionEvent extends UIEvent {
    public static inline var ACTION_START:String = "actionstart";
    public static inline var ACTION_END:String = "actionend";
    
    public var action:ActionType;
    public var repeater:Bool = false;
    
    public function new(type:String, action:ActionType, bubble:Null<Bool> = false, data:Dynamic = null) {
        super(type, bubble, data);
        this.action = action;
    }
    
    public override function clone():ActionEvent {
        var c:ActionEvent = new ActionEvent(this.type, this.action);
        c.type = this.type;
        c.bubble = this.bubble;
        c.target = this.target;
        c.data = this.data;
        c.canceled = this.canceled;
        c.relatedEvent = this.relatedEvent;
        c.action = this.action;
        c.repeater = this.repeater;
        postClone(c);
        return c;
    }
    
    public override function copyFrom(e:UIEvent) {
        var ae = cast(e, ActionEvent);
        this.action = ae.action;
        this.repeater = ae.repeater;
    }
}