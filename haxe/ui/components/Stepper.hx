package haxe.ui.components;

import haxe.ui.containers.VBox;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.DataBehaviour;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;

@:composite(Events, Builder)
class Stepper extends VBox {
    @:clonable @:behaviour(PosBehaviour, 0)    public var pos:Int;
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class PosBehaviour extends DataBehaviour {
    public override function validateData() {
        var event = new UIEvent(UIEvent.CHANGE);
        _component.dispatch(event);
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends CompositeBuilder {
    private var _stepper:Stepper;
    
    public function new(stepper:Stepper) {
        super(stepper);
        _stepper = stepper;
    }
    
    public override function create() {
        var button = new Button();
        button.styleNames = "stepper-button stepper-inc";
        button.id = "stepper-inc";
        button.repeater = true;
        button.repeatInterval = 100;
        _stepper.addComponent(button);
        
        var button = new Button();
        button.styleNames = "stepper-button stepper-deinc";
        button.id = "stepper-deinc";
        button.repeater = true;
        button.repeatInterval = 100;
        _stepper.addComponent(button);
    }
}

//***********************************************************************************************************
// Composite Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Events extends haxe.ui.core.Events {
    private var _stepper:Stepper;
    
    public function new(stepper:Stepper) {
        super(stepper);
        _stepper = stepper;
    }
    
    public override function register() {
        var button:Button = _stepper.findComponent("stepper-inc", Button);
        if (!button.hasEvent(MouseEvent.CLICK, onInc)) {
            button.registerEvent(MouseEvent.CLICK, onInc);
        }
        
        var button:Button = _stepper.findComponent("stepper-deinc", Button);
        if (!button.hasEvent(MouseEvent.CLICK, onDeinc)) {
            button.registerEvent(MouseEvent.CLICK, onDeinc);
        }
    }
    
    public override function unregister() {
        var button:Button = _stepper.findComponent("stepper-inc", Button);
        button.unregisterEvent(MouseEvent.CLICK, onInc);
        
        var button:Button = _stepper.findComponent("stepper-deinc", Button);
        button.unregisterEvent(MouseEvent.CLICK, onDeinc);
    }
    
    private function onInc(event:MouseEvent) {
        increment();
    }
    
    private function onDeinc(event:MouseEvent) {
        deincrement();
    }
    
    private function increment() {
        var newPos = _stepper.pos;
        newPos++;
        _stepper.pos = newPos;
    }
    
    private function deincrement() {
        var newPos = _stepper.pos;
        newPos--;
        _stepper.pos = newPos;
    }
}