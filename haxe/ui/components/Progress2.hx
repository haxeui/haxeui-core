package haxe.ui.components;

import haxe.ui.animation.Animation;
import haxe.ui.animation.AnimationManager;
import haxe.ui.components.Range;
import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.IDirectionalComponent;
import haxe.ui.core.ValueBehaviour;
import haxe.ui.util.Variant;

class Progress2 extends Range implements IDirectionalComponent {
    public function new() {
        super();
    }
    
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(IndeterminateBehaviour)   public var indeterminate:Bool;
    
    public var pos(get, set):Float;
    private function get_pos():Float {
        return end;
    }
    private function set_pos(value:Float):Float {
        end = value;
        return value;
    }
    
    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function set_min(value:Float):Float {
        super.set_min(value);
        start = value;
        return value;
    }
    
    private override function get_value():Variant {
        return end;
    }
    
    private override function set_value(value:Variant):Variant {
        end = value;
        return value;
    }
}

//***********************************************************************************************************
// Default Behaviours
//***********************************************************************************************************
private class IndeterminateBehaviour extends ValueBehaviour {
    private var _animation:Animation;
    
    public function new(component:Component) {
        super(component, false);
    }
    
    public override function get():Variant {
        return _value;
    }
    
    public override function set(value:Variant) {
        if (value == _value) {
            return;
        }
        
        if (value == true) {
            startIndeterminateAnimation();
        } else {
            stopIndeterminateAnimation();
        }
    }
    
    private function startIndeterminateAnimation() {
        var animationId:String = _component.getClassProperty("animation.indeterminate");
        if (animationId == null) {
            return;
        }
        _animation = AnimationManager.instance.loop(animationId, ["target" => _component]);
    }

    private function stopIndeterminateAnimation() {
        if (_animation != null) {
            _animation.stop();
            _animation = null;
        }
    }
}