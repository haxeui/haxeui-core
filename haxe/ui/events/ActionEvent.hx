package haxe.ui.events;
import haxe.ui.actions.ActionType;

class ActionEvent extends UIEvent {
    public static inline var ACTION_START:String = "actionStart";
    public static inline var ACTION_END:String = "actionEnd";
    
    public var action:ActionType;
    
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
        c.action = this.action;
        postClone(c);
        return c;
    }
}