package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.IDirectionalComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.UIEvent;
import haxe.ui.core.ValueBehaviour;

class Range extends InteractiveComponent implements IDirectionalComponent {
    
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(ValueBehaviour, 0.)   public var start:Float;
    @:behaviour(ValueBehaviour, 100.) public var end:Float;
    @:behaviour(ValueBehaviour, 0.)   public var min:Float;
    @:behaviour(ValueBehaviour, 100.) public var max:Float;
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
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
