package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.IDirectionalComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.UIEvent;
import haxe.ui.core.ValueBehaviour;

class Range extends InteractiveComponent implements IDirectionalComponent {
    public function new() {
        super();
    }
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "start" => new ValueBehaviour(this, 0.),
            "end" => new ValueBehaviour(this, 100.),
            "min" => new ValueBehaviour(this, 0.),
            "max" => new ValueBehaviour(this, 100.)
        ]);
    }
    
    private override function createChildren() {
        if (findComponent("value") == null) {
            var v = new Component();
            v.id = '${cssName}-value';
            v.addClass('${cssName}-value', false);
            addComponent(v);
        }
    }
    
    private override function get_cssName():String {
        return "range";
    }
    
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    public var start(get, set):Float;
    private function get_start():Float {
        return behaviourGet("start");
    }
    private function set_start(value:Float):Float {
        behaviourSet("start", value);
        return value;
    }
    
    public var end(get, set):Float;
    private function get_end():Float {
        return behaviourGet("end");
    }
    private function set_end(value:Float):Float {
        behaviourSet("end", value);
        return value;
    }

    public var min(get, set):Float;
    private function get_min():Float {
        return behaviourGet("min");
    }
    private function set_min(value:Float):Float {
        behaviourSet("min", value);
        return value;
    }
    
    public var max(get, set):Float;
    private function get_max():Float {
        return behaviourGet("max");
    }
    private function set_max(value:Float):Float {
        behaviourSet("max", value);
        return value;
    }
    
    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************
    private override function validateData() {
        var startValue = behaviourGet("start");
        var endValue = behaviourGet("end");
        var minValue = behaviourGet("min");
        var maxValue = behaviourGet("max");

        if (startValue < minValue) {
            startValue = minValue;
        }
        
        if (endValue < minValue) {
            endValue = minValue;
        }
        
        if (startValue > maxValue) {
            startValue = maxValue;
        }
        
        if (endValue > maxValue) {
            endValue = maxValue;
        }
        
        start = startValue;
        end = endValue;
        
        var changeEvent:UIEvent = new UIEvent(UIEvent.CHANGE);
        dispatch(changeEvent);
    }
}
