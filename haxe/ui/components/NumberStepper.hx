package haxe.ui.components;

import haxe.ui.containers.HBox;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.DataBehaviour;
import haxe.ui.core.FocusEvent;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;

@:composite(Events, Builder)
class NumberStepper extends HBox {
    @:clonable @:behaviour(PosBehaviour, 0)    public var pos:Int;
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class PosBehaviour extends DataBehaviour {
    public override function validateData() {
        var textfield:TextField = _component.findComponent("stepper-textfield", TextField);
        textfield.text = Std.string(_value);
        
        var event = new UIEvent(UIEvent.CHANGE);
        _component.dispatch(event);
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends CompositeBuilder {
    private var _stepper:NumberStepper;
    
    public function new(stepper:NumberStepper) {
        super(stepper);
        _stepper = stepper;
    }
    
    public override function create() {
        _stepper.addClass("textfield");
        
        var textfield = new TextField();
        textfield.addClass("stepper-textfield");
        textfield.id = "stepper-textfield";
        _stepper.addComponent(textfield);
        
        var step = new Stepper();
        step.addClass("stepper-step");
        step.id = "stepper-step";
        _stepper.addComponent(step);
    }
}


//***********************************************************************************************************
// Composite Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Events extends haxe.ui.core.Events {
    private var _stepper:NumberStepper;
    
    public function new(stepper:NumberStepper) {
        super(stepper);
        _stepper = stepper;
    }
    
    public override function register() {
        if (!hasEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel)) {
            registerEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        }
        
        var textfield:TextField = _stepper.findComponent("stepper-textfield", TextField);
        if (!textfield.hasEvent(FocusEvent.FOCUS_IN, onTextFieldFocusIn)) {
            textfield.registerEvent(FocusEvent.FOCUS_IN, onTextFieldFocusIn);
        }
        if (!textfield.hasEvent(FocusEvent.FOCUS_OUT, onTextFieldFocusOut)) {
            textfield.registerEvent(FocusEvent.FOCUS_OUT, onTextFieldFocusOut);
        }
        if (!textfield.hasEvent(UIEvent.CHANGE, onTextFieldChange)) {
            textfield.registerEvent(UIEvent.CHANGE, onTextFieldChange);
        }
        
        var step:Stepper = _stepper.findComponent("stepper-step", Stepper);
        if (!step.hasEvent(UIEvent.CHANGE, onStepChange)) {
            step.registerEvent(UIEvent.CHANGE, onStepChange);
        }
        if (!step.hasEvent(MouseEvent.MOUSE_DOWN, onStepMouseDown)) {
            step.registerEvent(MouseEvent.MOUSE_DOWN, onStepMouseDown);
        }
    }
    
    public override function unregister() {
        unregisterEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        
        var textfield:TextField = _stepper.findComponent("stepper-textfield", TextField);
        textfield.unregisterEvent(FocusEvent.FOCUS_IN, onTextFieldFocusIn);
        textfield.unregisterEvent(FocusEvent.FOCUS_OUT, onTextFieldFocusOut);
        textfield.unregisterEvent(UIEvent.CHANGE, onTextFieldChange);
        
        var step:Stepper = _stepper.findComponent("stepper-step", Stepper);
        step.unregisterEvent(UIEvent.CHANGE, onStepChange);
        step.unregisterEvent(MouseEvent.MOUSE_DOWN, onStepMouseDown);
    }
    
    private function onMouseWheel(event:MouseEvent) {
        var textfield:TextField = _stepper.findComponent("stepper-textfield", TextField);
        textfield.focus = true;
        
        var step:Stepper = _stepper.findComponent("stepper-step", Stepper);
        if (event.delta > 0) {
            step.increment();
        } else {
            step.deincrement();
        }
    }
    
    private function onStepChange(event:UIEvent) {
        var step:Stepper = _stepper.findComponent("stepper-step", Stepper);
        _stepper.pos = step.pos;
    }
    
    private function onStepMouseDown(event:MouseEvent) {
        var textfield:TextField = _stepper.findComponent("stepper-textfield", TextField);
        textfield.focus = true;
    }
    
    private function onTextFieldFocusIn(event:FocusEvent) {
        _stepper.addClass(":active");
    }
    
    private function onTextFieldFocusOut(event:FocusEvent) {
        _stepper.removeClass(":active");
    }
    
    private function onTextFieldChange(event:UIEvent) {
        var step:Stepper = _stepper.findComponent("stepper-step", Stepper);
        var textfield:TextField = _stepper.findComponent("stepper-textfield", TextField);
        step.pos = Std.parseInt(textfield.text);
    }
}