package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.IDirectionalComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.InvalidatingBehaviour;
import haxe.ui.core.UIEvent;

class Range extends InteractiveComponent implements IDirectionalComponent {
    public function new() {
        super();
        _behaviourUpdateOrder = ["min", "max", "start", "end"];
    }
    
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(InvalidatingBehaviour, 0.)   public var start:Float;
    @:behaviour(InvalidatingBehaviour, 100.) public var end:Float;
    @:behaviour(InvalidatingBehaviour, 0.)   public var min:Float;
    @:behaviour(InvalidatingBehaviour, 100.) public var max:Float;
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createChildren() {
        super.createChildren();
        if (findComponent("value") == null) {
            var v = new Component();
            v.id = '${cssName}-value';
            v.addClass('${cssName}-value', false);
            addComponent(v);
        }
    }
    
    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
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
        
        if (startValue != null && minValue != null && startValue < minValue) {
            startValue = minValue;
        }
        
        if (endValue != null && minValue != null && endValue < minValue) {
            endValue = minValue;
        }
        
        if (startValue != null && maxValue != null && startValue > maxValue) {
            startValue = maxValue;
        }
        
        if (endValue != null && maxValue != null && endValue > maxValue) {
            endValue = maxValue;
        }

        var changed = false;
        if (startValue != null) {
            start = startValue;
            changed = true;
        }
        if (endValue != null) {
            end = endValue;
            changed = true;
        }
        
        if (changed == true) {
            var changeEvent:UIEvent = new UIEvent(UIEvent.CHANGE);
            dispatch(changeEvent);
        }
    }
}
