package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.IDirectionalComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.InvalidatingBehaviour;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.Screen;
import haxe.ui.core.UIEvent;
import haxe.ui.util.MathUtil;
import haxe.ui.util.Point;

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
    @:behaviour(InvalidatingBehaviour, 0)    public var precision:Int;
    @:behaviour(InvalidatingBehaviour, -1)   public var step:Float;
    
    private var _events:Events = null;
    public var interactive(get, set):Bool;
    private function get_interactive():Bool {
        return (_events != null);
    }
    private function set_interactive(value:Bool):Bool {
        if (value == interactive || native == true) {
            return value;
        }
        
        if (value == true) {
            _events = new Events(this);
        } else {
            _events = null;
        }
        
        return value;
    }
    
    //***********************************************************************************************************
    // Private API
    //***********************************************************************************************************
    private function posFromCoord(coord:Point):Float {
        return behaviourCall("posFromCoord", coord); 
    }
    
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
    
    private override function destroyChildren() {
        super.destroyChildren();
        if (_events != null) {
            _events.unregister();
            _events = null;
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

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.components.Range)
private class Events {
    private var _range:Range;
    
    public function new(range:Range) {
        _range = range;
        register();
    }
    
    public function register() {
        _range.registerEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
    }
    
    public function unregister() {
        _range.unregisterEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
    }
    
    private function onMouseDown(e:MouseEvent) {
        var pt:Point = new Point(e.localX, e.localY);
        var pos = _range.posFromCoord(pt);
        applyPos(pos);        
        
        Screen.instance.registerEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
        Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
    }
    
    private function onScreenMouseUp(e:MouseEvent) {
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
    }
    
    private function onScreenMouseMove(e:MouseEvent) {
        var pt:Point = new Point(e.screenX - _range.left, e.screenY - _range.top);
        var pos:Float = _range.posFromCoord(pt);
        applyPos(pos);
    }
    
    private function applyPos(pos:Float) {
        pos = MathUtil.round(pos, _range.precision);
        if (_range.step > 0) {
            pos = Math.ceil(pos / _range.step) * _range.step;
        }
        
        if (Std.is(_range, Progress2)) {
            cast(_range, Progress2).pos = pos;
            return;
        }
        
        var d1 = _range.end - _range.start;
        var d2 = pos - _range.start;

        if (d2 < d1 / 2) {
            _range.start = pos;
        } else if (d2 >= d1 / 2) {
            _range.end = pos;
        } else if (pos > _range.start) {
            _range.end = pos;
        } else if (pos < _range.end) {
            _range.start = pos;
        }
    }
}
