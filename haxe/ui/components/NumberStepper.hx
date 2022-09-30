package haxe.ui.components;

import haxe.ui.actions.ActionType;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.components.Button;
import haxe.ui.components.TextField;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.events.ActionEvent;
import haxe.ui.events.FocusEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.locale.Formats;
import haxe.ui.styles.Style;
import haxe.ui.util.MathUtil;
import haxe.ui.util.StringUtil;
import haxe.ui.util.Timer;

/**
 * A normal stepper that can be used to increment or decrement a number with the 
 * visual arrow buttons, arrow keys or by normally typing in the stepper's text field.
 */
@:composite(Events, Builder)
class NumberStepper extends InteractiveComponent {

    /**
     * The actual value of the number stepper.
     */
    @:clonable @:behaviour(PosBehaviour, 0)                             public var pos:Null<Float>;

    /**
     * The number displayed inside of the stepper.
     * 
     * `value` is used as a universal way to access the value a component is based on. in this case its the number inside of the stepper.
     */
    @:clonable @:value(pos)                                             public var value:Dynamic;

    /**
     * The amount by which the value is increased or decreased when the user presses the up or down button.
     */
    @:clonable @:behaviour(DefaultBehaviour, 1)                         public var step:Float;

    /**
     * The Highest value this stepper can get to, even when set through code.
     */
    @:clonable @:behaviour(DefaultBehaviour, null)                      public var max:Null<Float>;

    /**
     * The lowest value this stepper can get to, even when set through code.
     */
    @:clonable @:behaviour(DefaultBehaviour, null)                      public var min:Null<Float>;

    /**
     * The amount of numbers displayed after the decimal point.
     * 
     * `0` or `null` means that no decimal point is displayed. defaults to `null`.
     */
    @:clonable @:behaviour(DefaultBehaviour, null)                      public var precision:Null<Int>;

    /**
     * If true, overflowing values will be fixed to the closest valid value.
     * 
     * for example, if the user types `20`, but the maximum is `10`, the value will automatically be set to `10`.
     */
    @:clonable @:behaviour(DefaultBehaviour, false)                     public var autoCorrect:Bool;
    
    /**
     * The character that will be used to seperate decimals (eg 100.00 or 100,00)
     */
    @:clonable @:behaviour(DefaultBehaviour, Formats.decimalSeperator)  public var decimalSeparator:String;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class PosBehaviour extends DataBehaviour {
    public override function validateData() {
        var stepper = cast(_component, NumberStepper);
        var preciseValue:Null<Float> = _value;
        if (preciseValue == null) {
            preciseValue = stepper.min;
        }
        
        preciseValue = MathUtil.clamp(preciseValue, stepper.min, stepper.max);
        var wasRounded = false;
        if (stepper.precision != null) {
            var newPreciseValue = MathUtil.round(preciseValue, stepper.precision);
            if (newPreciseValue != preciseValue) {
                preciseValue = newPreciseValue;
                wasRounded = true;
            }
        }
        _value = preciseValue;
        
        var stringValue = StringUtil.padDecimal(preciseValue, stepper.precision);
        var value:TextField = stepper.findComponent("value", TextField);
        var carentIndex = value.caretIndex;
        stringValue = StringTools.replace(stringValue, ",", ".");
        stringValue = StringTools.replace(stringValue, ".", stepper.decimalSeparator);
        value.text = stringValue;
        if (wasRounded) {
            value.caretIndex = stringValue.length;
        } else {
            value.caretIndex = carentIndex;
        }
        
        var event = new UIEvent(UIEvent.CHANGE);
        event.previousValue = _previousValue;
        event.value = _value;
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
        _stepper.layout = new StandardLayout();
    }
    
    public override function create() {
        var value = new TextField();
        value.id = "value";
        value.addClass("stepper-value");
        value.scriptAccess = false;
        value.allowFocus = false;
        value.restrictChars = "0-9\\-\\.\\,";
        _stepper.addComponent(value);
        
        var deinc = new Button();
        deinc.id = "deinc";
        deinc.addClass("stepper-deinc");
        deinc.allowFocus = false;
        deinc.scriptAccess = false;
        deinc.repeater = true;
        _stepper.addComponent(deinc);

        var inc = new Button();
        inc.id = "inc";
        inc.addClass("stepper-inc");
        inc.allowFocus = false;
        inc.scriptAccess = false;
        inc.repeater = true;
        _stepper.addComponent(inc);
    }
    
    public override function applyStyle(style:Style) {
        if (style.layout == "classic") {
            _stepper.layout = new ClassicLayout();
        } else if (style.layout == null && !(_stepper.layout is StandardLayout)) {
            _stepper.layout = new StandardLayout();
        }
        
        var value:TextField = _stepper.findComponent("value", TextField);
        if (value != null &&
            (value.customStyle.color != style.color ||
            value.customStyle.fontName != style.fontName ||
            value.customStyle.fontSize != style.fontSize ||
            value.customStyle.cursor != style.cursor ||
            value.customStyle.textAlign != style.textAlign)) {

            value.customStyle.color = style.color;
            value.customStyle.fontName = style.fontName;
            value.customStyle.fontSize = style.fontSize;
            value.customStyle.cursor = style.cursor;
            value.customStyle.textAlign = style.textAlign;
            value.invalidateComponentStyle();
        }
    }
}

//***********************************************************************************************************
// Composite Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Events extends haxe.ui.events.Events {
    private var _stepper:NumberStepper;

    public function new(stepper:NumberStepper) {
        super(stepper);
        _stepper = stepper;
    }
    
    public override function register() {
        if (!_stepper.hasEvent(MouseEvent.CLICK, onClick)) {
            _stepper.registerEvent(MouseEvent.CLICK, onClick);
        }
        if (!_stepper.hasEvent(FocusEvent.FOCUS_IN, onFocusIn)) {
            _stepper.registerEvent(FocusEvent.FOCUS_IN, onFocusIn);
        }
        if (!_stepper.hasEvent(FocusEvent.FOCUS_OUT, onFocusOut)) {
            _stepper.registerEvent(FocusEvent.FOCUS_OUT, onFocusOut);
        }
        if (!_stepper.hasEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel)) {
            _stepper.registerEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        }
        
        var value:TextField = _stepper.findComponent("value", TextField);
        if (!value.hasEvent(UIEvent.CHANGE, onValueFieldChange)) {
            value.registerEvent(UIEvent.CHANGE, onValueFieldChange);
        }
        
        var deinc:Button = _stepper.findComponent("deinc", Button);
        if (!deinc.hasEvent(MouseEvent.CLICK, onDeinc)) {
            deinc.registerEvent(MouseEvent.CLICK, onDeinc);
        }
        
        var inc:Button = _stepper.findComponent("inc", Button);
        if (!inc.hasEvent(MouseEvent.CLICK, onInc)) {
            inc.registerEvent(MouseEvent.CLICK, onInc);
        }
        if (!hasEvent(ActionEvent.ACTION_START, onActionStart)) {
            registerEvent(ActionEvent.ACTION_START, onActionStart);
        }
    }
    
    public override function unregister() {
        _stepper.unregisterEvent(MouseEvent.CLICK, onClick);
        _stepper.unregisterEvent(FocusEvent.FOCUS_IN, onFocusIn);
        _stepper.unregisterEvent(FocusEvent.FOCUS_OUT, onFocusOut);
        _stepper.unregisterEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel);
            
        var value:TextField = _stepper.findComponent("value", TextField);
        value.unregisterEvent(UIEvent.CHANGE, onValueFieldChange);
        
        var deinc:Button = _stepper.findComponent("deinc", Button);
        deinc.unregisterEvent(MouseEvent.CLICK, onDeinc);
        
        var inc:Button = _stepper.findComponent("inc", Button);
        inc.unregisterEvent(MouseEvent.CLICK, onInc);
        unregisterEvent(ActionEvent.ACTION_START, onActionStart);
    }
    
    private var _autoCorrectTimer:Timer = null;
    private function onValueFieldChange(event:UIEvent) {
        if (_stepper.autoCorrect == true) {
            if (_autoCorrectTimer != null) {
               _autoCorrectTimer.stop();
               _autoCorrectTimer = null;
            }
            
            _autoCorrectTimer = new Timer(350, onAutoCorrectTimer);
        } else {
            var newValue = ValueHelper.validateValue(_stepper);
            if (newValue != null) {
                _stepper.pos = newValue;
            }
        }
    }
    
    private function onAutoCorrectTimer() {
        _autoCorrectTimer.stop();
        _autoCorrectTimer = null;
        
        var value:TextField = _stepper.findComponent("value", TextField);
        var parsedValue = Std.parseFloat(value.text);
        _stepper.pos = MathUtil.clamp(parsedValue, _stepper.min, _stepper.max);
        var stringValue = StringUtil.padDecimal(_stepper.pos, _stepper.precision);
        stringValue = StringTools.replace(stringValue, ",", ".");
        stringValue = StringTools.replace(stringValue, ".", _stepper.decimalSeparator);
        value.text = stringValue;
    }
    
    private function onDeinc(event:MouseEvent) {
        _stepper.focus = true;
        ValueHelper.deincrementValue(_stepper);
    }
    
    private function onInc(event:MouseEvent) {
        _stepper.focus = true;
        ValueHelper.incrementValue(_stepper);
    }
    
    private function isInScroller():Bool {
        var p = _stepper.parentComponent;
        while (p != null) {
            if (p.isScroller) {
                var vscroll = p.findComponent("scrollview-vscroll", Component);
                if (vscroll != null && vscroll.hidden == false) {
                    return true;
                }
            }
            p = p.parentComponent;
        }
        return false;
    }
    
    private function onMouseWheel(event:MouseEvent) {
        if (isInScroller() && _stepper.focus == false) {
            return;
        }
        event.cancel();
        _stepper.focus = true;
        if (event.delta > 0) {
            ValueHelper.incrementValue(_stepper);
        } else {
            ValueHelper.deincrementValue(_stepper);
        }
    }
    
    private function onClick(_) {
        _stepper.focus = true;
    }
    
    private function onFocusIn(event:FocusEvent) {
        var value:TextField = _stepper.findComponent("value", TextField);
        value.getTextInput().focus();
    }
    
    private function onFocusOut(event:FocusEvent) {
        var value:TextField = _stepper.findComponent("value", TextField);
        value.getTextInput().blur();
    }
    
    private function onActionStart(event:ActionEvent) {
        switch (event.action) {
            case ActionType.DOWN:
                ValueHelper.deincrementValue(_stepper);
                event.repeater = true;
            case ActionType.UP:
                ValueHelper.incrementValue(_stepper);
                event.repeater = true;
            case _:      
        }
    }
}

//***********************************************************************************************************
// Layouts
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class StandardLayout extends DefaultLayout {
    private override function resizeChildren() {
        var value = findComponent("value", TextField);
        var deinc = findComponent("deinc", Button);
        var inc = findComponent("inc", Button);
        
        var u = usableSize;
        
        deinc.height = u.height - (borderSize * 2);
        value.width = u.width - (deinc.width + inc.width);
        inc.height = u.height - (borderSize * 2);
    }
    
    private override function repositionChildren() {
        var value = findComponent("value", TextField);
        var deinc = findComponent("deinc", Button);
        var inc = findComponent("inc", Button);
        
        deinc.left = paddingLeft + borderSize;
        deinc.top = paddingTop + borderSize;
        
        value.left = deinc.left + deinc.width;
        value.top = paddingTop + marginTop(value);
        
        inc.left = value.left + value.width - borderSize - borderSize;
        inc.top = paddingTop + borderSize;
    }
    
    private override function get_borderSize():Float {
        if (_component.style == null) {
            return 0;
        }

        var n = _component.style.fullBorderSize;
        return n;
    }
}

@:dox(hide) @:noCompletion
private class ClassicLayout extends DefaultLayout {
    private override function resizeChildren() {
        var value = findComponent("value", TextField);
        var deinc = findComponent("deinc", Button);
        var inc = findComponent("inc", Button);
        
        var u = usableSize;
        u.height -= borderSize * 2;
        
        deinc.height = u.height / 2;
        value.width = u.width - deinc.width;
        inc.height = u.height / 2;
    }
    
    private override function repositionChildren() {
        var value = findComponent("value", TextField);
        var deinc = findComponent("deinc", Button);
        var inc = findComponent("inc", Button);
        
        var u = usableSize;
        u.height -= borderSize * 2;
        
        deinc.left = u.width - deinc.width - paddingRight - borderSize;
        deinc.top = u.height - inc.height - paddingBottom - borderSize + marginTop(deinc) + (borderSize * 2);
        
        value.left = paddingLeft;
        value.top = paddingTop + marginTop(value);
        
        inc.left = u.width - deinc.width - paddingRight - borderSize;
        inc.top = paddingTop + borderSize;
    }
    
    private override function get_borderSize():Float {
        var n = super.get_borderSize();
        return n;
    }
}

private class ValueHelper {
    public static function validateValue(stepper:NumberStepper):Null<Float> {
        var value = stepper.findComponent("value", TextField);
        var textValue = value.text;
        var min = stepper.min;
        var max = stepper.max;

        if (textValue != null) {
            textValue = StringTools.replace(textValue, ",", ".");
            textValue = StringTools.replace(textValue, stepper.decimalSeparator, ".");
        }
        var parsedValue:Null<Float> = Std.parseFloat(textValue);
        
        var valid = StringUtil.countTokens(textValue, ".") <= 1;
        if (textValue == null || StringTools.trim(textValue) == "") {
            valid = false;
        }
        
        if (Math.isNaN(parsedValue)) {
            valid = false;
        }
        
        if (min != null && parsedValue < min) {
            valid = false;
        }
        
        if (max != null && parsedValue > max) {
            valid = false;
        }
        
        if (valid == false) {
            parsedValue = null;
            stepper.addClass("invalid-value");
        } else {
            stepper.removeClass("invalid-value");
        }
        
        return parsedValue;
    }
    
    public static function incrementValue(stepper:NumberStepper) {
        var value = stepper.findComponent("value", TextField);
        var textValue = value.text;
        var min = stepper.min;
        var max = stepper.max;
        var newValue:Float = stepper.pos;
        
        if (textValue == null || StringTools.trim(textValue) == "") {
            if (min != null) {
                newValue = min;
            }
        } else {
            newValue += stepper.step;
        }
        
        if (max != null && newValue > max) {
            newValue = max;
        }
        
        stepper.pos = newValue;
    }
    
    public static function deincrementValue(stepper:NumberStepper) {
        var value = stepper.findComponent("value", TextField);
        var textValue = value.text;
        var min = stepper.min;
        var newValue:Float = stepper.pos;
        
        if (textValue == null || StringTools.trim(textValue) == "") {
            if (min != null) {
                newValue = min;
            }
        } else {
            newValue -= stepper.step;
        }
        
        if (min != null && newValue < min) {
            newValue = min;
        }
        
        stepper.pos = newValue;
    }
}