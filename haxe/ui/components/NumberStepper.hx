package haxe.ui.components;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.events.Events;
import haxe.ui.events.FocusEvent;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.layouts.HorizontalLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.MathUtil;
import haxe.ui.util.StringUtil;
import haxe.ui.util.Variant;

@:composite(Events, Builder, HorizontalLayout)
class NumberStepper extends InteractiveComponent {
    @:clonable @:behaviour(PosBehaviour, 0)             public var pos:Float;
    @:clonable @:value(pos)                             public var value:Dynamic;
    @:clonable @:behaviour(StepBehaviour, 1)            public var step:Float;
    @:clonable @:behaviour(MinBehaviour, null)          public var min:Null<Float>;
    @:clonable @:behaviour(MaxBehaviour, null)          public var max:Null<Float>;
    @:clonable @:behaviour(PrecisionBehaviour, null)    public var precision:Null<Int>;
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class PosBehaviour extends DataBehaviour {
    public override function validateData() {
        var step:Stepper = _component.findComponent("stepper-step", Stepper);
        var preciseValue:Float = _value;
        if (step.precision != null) {
            preciseValue = MathUtil.round(preciseValue, step.precision);
        }

        preciseValue = MathUtil.clamp(preciseValue, step.min, step.max);
        step.pos = preciseValue;
        
        var textfield:TextField = _component.findComponent("stepper-textfield", TextField);
        var value = StringUtil.padDecimal(preciseValue, step.precision);
        textfield.text = value;
        
        var event = new UIEvent(UIEvent.CHANGE);
        _component.dispatch(event);
    }
}

@:dox(hide) @:noCompletion
private class StepBehaviour extends DefaultBehaviour {
    public override function get():Variant {
        var step:Stepper = _component.findComponent("stepper-step", Stepper);
        return step.step;
    }
    
    public override function set(value:Variant) {
        var step:Stepper = _component.findComponent("stepper-step", Stepper);
        step.step = value;
    }
}

@:dox(hide) @:noCompletion
private class MinBehaviour extends DefaultBehaviour {
    public override function get():Variant {
        var step:Stepper = _component.findComponent("stepper-step", Stepper);
        return step.min;
    }
    
    public override function set(value:Variant) {
        var step:Stepper = _component.findComponent("stepper-step", Stepper);
        step.min = value;
    }
}

@:dox(hide) @:noCompletion
private class MaxBehaviour extends DefaultBehaviour {
    public override function get():Variant {
        var step:Stepper = _component.findComponent("stepper-step", Stepper);
        return step.max;
    }
    
    public override function set(value:Variant) {
        var step:Stepper = _component.findComponent("stepper-step", Stepper);
        step.max = value;
    }
}

@:dox(hide) @:noCompletion
private class PrecisionBehaviour extends DefaultBehaviour {
    public override function get():Variant {
        var step:Stepper = _component.findComponent("stepper-step", Stepper);
        return step.precision;
    }
    
    public override function set(value:Variant) {
        var step:Stepper = _component.findComponent("stepper-step", Stepper);
        step.precision = value;
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
		textfield.restrictChars = "0-9\\-\\.\\,";
        _stepper.addComponent(textfield);
        
        var step = new Stepper();
        step.addClass("stepper-step");
        step.id = "stepper-step";
        _stepper.addComponent(step);
    }
    
    public override function applyStyle(style:Style) {
        var textfield:TextField = _stepper.findComponent(TextField);
        if (textfield != null &&
            (textfield.customStyle.color != style.color ||
            textfield.customStyle.fontName != style.fontName ||
            textfield.customStyle.fontSize != style.fontSize ||
            textfield.customStyle.cursor != style.cursor ||
            textfield.customStyle.textAlign != style.textAlign)) {

            textfield.customStyle.color = style.color;
            textfield.customStyle.fontName = style.fontName;
            textfield.customStyle.fontSize = style.fontSize;
            textfield.customStyle.cursor = style.cursor;
            textfield.customStyle.textAlign = style.textAlign;
            textfield.invalidateComponentStyle();
        }
    }
}


//***********************************************************************************************************
// Composite Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Events extends haxe.ui.events.Events {
    private var _stepper:NumberStepper;
    
    public function new(stepper:NumberStepper) {
        super(stepper);
        _stepper = stepper;
    }
    
    public override function register() {
        if (!hasEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel)) {
            registerEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        }
		if (!_stepper.hasEvent(KeyboardEvent.KEY_DOWN, onKeyDown)) {
            _stepper.registerEvent(KeyboardEvent.KEY_DOWN, onKeyDown);
        }
        
        var textfield:TextField = _stepper.findComponent("stepper-textfield", TextField);
        if (!textfield.hasEvent(KeyboardEvent.KEY_UP, onTextFieldKeyUp)) {
            textfield.registerEvent(KeyboardEvent.KEY_UP, onTextFieldKeyUp);
        }
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
		_stepper.unregisterEvent(KeyboardEvent.KEY_DOWN, onKeyDown);
        
        var textfield:TextField = _stepper.findComponent("stepper-textfield", TextField);
        textfield.unregisterEvent(KeyboardEvent.KEY_UP, onTextFieldKeyUp);
        textfield.unregisterEvent(FocusEvent.FOCUS_IN, onTextFieldFocusIn);
        textfield.unregisterEvent(FocusEvent.FOCUS_OUT, onTextFieldFocusOut);
        textfield.unregisterEvent(UIEvent.CHANGE, onTextFieldChange);
        
        var step:Stepper = _stepper.findComponent("stepper-step", Stepper);
        step.unregisterEvent(UIEvent.CHANGE, onStepChange);
        step.unregisterEvent(MouseEvent.MOUSE_DOWN, onStepMouseDown);
    }
	
	private function onKeyDown(event:KeyboardEvent) {
		var step:Stepper = _stepper.findComponent("stepper-step", Stepper);
		if (event.keyCode == 38 || event.keyCode == 39 || event.keyCode == 107) { // ArrowUp, ArrowRight, or add(+)
			step.increment();
		}
		if (event.keyCode == 40 || event.keyCode == 37 || event.keyCode == 109) { // ArrowDown, ArrowLeft, or minus(-)
			step.deincrement();
		}
		if (event.keyCode == 36) { // Home
			step.pos = step.min;
		}
		if (event.keyCode == 35) { // End
			step.pos = step.max;
		}
	}
    
    private function onMouseWheel(event:MouseEvent) {
        event.cancel();
        
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

    private function onTextFieldKeyUp(event:KeyboardEvent) {
        if (event.keyCode == 13) { // Enter
            var textfield:TextField = _stepper.findComponent("stepper-textfield", TextField);
            textfield.focus = false;
        }
        event.cancel();
    }
    
    private function onTextFieldFocusIn(event:FocusEvent) {
        _stepper.addClass(":active");
    }
    
    private function onTextFieldFocusOut(event:FocusEvent) {
        _stepper.removeClass(":active");
        var textfield:TextField = _stepper.findComponent("stepper-textfield", TextField);
        if (textfield != null) {
            _stepper.pos = MathUtil.clamp(Std.parseFloat(textfield.text), _stepper.min, _stepper.max);
            textfield.text = Std.string(_stepper.pos);
        } else {
            event.cancel();
        }
    }
    
    private function onTextFieldChange(event:UIEvent) {
        var step:Stepper = _stepper.findComponent("stepper-step", Stepper);
        var textfield:TextField = _stepper.findComponent("stepper-textfield", TextField);
        var lastChar:String = textfield.text.charAt(textfield.text.length - 1);
        var maxCappedVal:Float = Math.min(Std.parseFloat(textfield.text), _stepper.max);
        textfield.text = Std.string(maxCappedVal);
        // if lastChar was not a digit, it was an allowed chars and should be added back (ex: decimal, dash, comma)
        if (Std.parseInt(lastChar) == null) {
            textfield.text += lastChar;
        }
    }
}