package haxe.ui.components;

import haxe.ui.containers.VBox;
import haxe.ui.core.Behaviour;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.DataBehaviour;
import haxe.ui.core.DefaultBehaviour;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.util.MathUtil;
import haxe.ui.util.Variant;

@:composite(Events, Builder)
class Stepper extends VBox {
    @:clonable @:behaviour(PosBehaviour)                public var pos:Float;
    @:clonable @:behaviour(ValueBehaviour)              public var value:Variant;
    @:clonable @:behaviour(DefaultBehaviour, 1)         public var step:Float;
    @:clonable @:behaviour(DefaultBehaviour, null)      public var min:Null<Float>;
    @:clonable @:behaviour(DefaultBehaviour, null)      public var max:Null<Float>;
    @:clonable @:behaviour(DefaultBehaviour, null)      public var precision:Null<Int>;
    @:call(IncBehaviour)                                public function increment();
    @:call(DeincBehaviour)                              public function deincrement();
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

@:dox(hide) @:noCompletion
private class ValueBehaviour extends DefaultBehaviour {
    public override function get():Variant {
        var stepper:Stepper = cast(_component, Stepper);
        return stepper.pos;
    }
    
    public override function set(value:Variant) {
        var stepper:Stepper = cast(_component, Stepper);
        stepper.pos = value;
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
        _stepper.increment();
    }
    
    private function onDeinc(event:MouseEvent) {
        _stepper.deincrement();
    }
}