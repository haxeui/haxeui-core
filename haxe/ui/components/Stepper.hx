package haxe.ui.components;

import haxe.ui.containers.VBox;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.events.Events;
import haxe.ui.util.MathUtil;
import haxe.ui.util.Variant;

@:composite(Events, Builder)
class Stepper extends VBox {
    @:clonable @:behaviour(PosBehaviour)                public var pos:Float;
    @:clonable @:value(pos)                             public var value:Dynamic;
    @:clonable @:behaviour(DefaultBehaviour, 1)         public var step:Float;
    @:clonable @:behaviour(DefaultBehaviour, null)      public var min:Null<Float>;
    @:clonable @:behaviour(DefaultBehaviour, null)      public var max:Null<Float>;
    @:clonable @:behaviour(DefaultBehaviour, null)      public var precision:Null<Int>;
    @:call(IncBehaviour)                                public function increment();
    @:call(DeincBehaviour)                              public function deincrement();

    /**
     Whether this button will dispatch multiple click events while the the mouse is pressed within it
    **/
    @:clonable @:behaviour(DefaultBehaviour, true)    public var repeater:Bool;

    /**
     How often this button will dispatch multiple click events while the the mouse is pressed within it
    **/
    @:clonable @:behaviour(DefaultBehaviour, 100)       public var repeatInterval:Int;
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class PosBehaviour extends DataBehaviour {
    public override function validateData() {
        var stepper:Stepper = cast(_component, Stepper);
        var v:Float = MathUtil.clamp(_value, stepper.min, stepper.max);
        stepper.pos = v;
        _value = v;
        var event = new UIEvent(UIEvent.CHANGE);
        _component.dispatch(event);
    }
}

@:dox(hide) @:noCompletion
private class IncBehaviour extends Behaviour {
    public override function call(param:Any = null):Variant {
        var stepper:Stepper = cast(_component, Stepper);
        var newPos = stepper.pos;
        newPos += stepper.step;

        if (stepper.max != null && newPos > stepper.max) {
            newPos = stepper.max;
        }

        if (stepper.precision != null) {
            newPos = MathUtil.round(newPos, stepper.precision);
        }

        stepper.pos = newPos;
        return null;
    }
}

@:dox(hide) @:noCompletion
private class DeincBehaviour extends Behaviour {
    public override function call(param:Any = null):Variant {
        var stepper:Stepper = cast(_component, Stepper);
        var newPos = stepper.pos;
        newPos -= stepper.step;

        if (stepper.min != null && newPos < stepper.min) {
            newPos = stepper.min;
        }

        if (stepper.precision != null) {
            newPos = MathUtil.round(newPos, stepper.precision);
        }

        stepper.pos = newPos;
        return null;
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
        button.repeater = _stepper.repeater;
        button.easeInRepeater = true;
        button.allowFocus = false;
        button.repeatInterval = _stepper.repeatInterval;
        _stepper.addComponent(button);

        var button = new Button();
        button.styleNames = "stepper-button stepper-deinc";
        button.id = "stepper-deinc";
        button.repeater = _stepper.repeater;
        button.easeInRepeater = true;
        button.allowFocus = false;
        button.repeatInterval = _stepper.repeatInterval;
        _stepper.addComponent(button);
    }
}

//***********************************************************************************************************
// Composite Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Events extends haxe.ui.events.Events {
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
        _stepper.increment();
    }

    private function onDeinc(event:MouseEvent) {
        _stepper.deincrement();
    }
}