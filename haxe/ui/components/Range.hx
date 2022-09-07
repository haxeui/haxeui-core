package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.core.IDirectionalComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.behaviours.InvalidatingBehaviour;
import haxe.ui.events.MouseEvent;
import haxe.ui.core.Screen;
import haxe.ui.events.UIEvent;
import haxe.ui.events.Events;
import haxe.ui.util.MathUtil;
import haxe.ui.geom.Point;
import haxe.ui.util.Variant;

/**
 * A range bar component, that starts from `min` and ends at `max`, defaults to 0-100.
 */
@:composite(RangeBuilder)
class Range extends InteractiveComponent implements IDirectionalComponent {

    /**
     * Creates a new range bar.
     * 
     * The position of the filled section is determined by the `start` and `end` properties.
     */
    private function new() {
        super();
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************

    /**
     * The value this range bar starts from, used to calculate 
     * the starting position of the filled section.
     */
    @:clonable @:behaviour(RangeMin, 0)                 public var min:Null<Float>;

    /**
     * The value this range bar ends at to, used calculate 
     * the ending position of the filled section.
     */
    @:clonable @:behaviour(RangeMax, 100)               public var max:Null<Float>;

    /**
     * The value this range bar's filled section is currently starting at.
     */
    @:clonable @:behaviour(RangeStart, null)            public var start:Null<Float>;

    /**
     * The value this range bar's filled section is currently ending at.
     */
    @:clonable @:behaviour(RangeEnd, 0)                 public var end:Float;

    /**
     * The amount of numbers after the decimal points that should be taken
     * into account when calculating the position of the filled section.
     */
    @:clonable @:behaviour(InvalidatingBehaviour)       public var precision:Int;

    /**
     * The amount of "offsetting" that should be applied to the position of the filled section.
     * 
     * for example: 
     * the range bar starts at 0 and ends at 100, and the offset is set to step is set to 10.
     * 
     * if we set the start to 6 and the end to 54, the visually filled range would be from 10 to 50.
     */
    @:clonable @:behaviour(InvalidatingBehaviour)       public var step:Float;

    /**
     * Whether or not to allow the uer to interact with the range bar.
     */
    @:clonable @:behaviour(AllowInteraction, false)     public var allowInteraction:Bool;

    private var virtualStart:Null<Float>;
    private var virtualEnd:Null<Float>;
    
    //***********************************************************************************************************
    // Private API
    //***********************************************************************************************************
    @:call(DefaultBehaviour)                        private function posFromCoord(coord:Point):Float;

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function get_cssName():String {
        return "range";
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class RangeMin extends DataBehaviour {
    public override function validateData() {
        var range:Range = cast(_component, Range);
        range.min = _value;
        if (range.start < range.min) {
            range.start = range.min;
        }
        _component.invalidateComponentLayout();
    }
}

@:dox(hide) @:noCompletion
private class RangeMax extends DataBehaviour {
    public override function validateData() {
        var range:Range = cast(_component, Range);
        range.max = _value;
        if (range.end > range.max) {
            range.end = range.max;
        }
        _component.invalidateComponentLayout();
    }
}

@:dox(hide) @:noCompletion
private class RangeStart extends DataBehaviour {
    public override function validateData() {
        var range:Range = cast(_component, Range);
        if (_value != null && _value < range.min) {
            _value = range.min;
        } else if (_value != null && _value > range.max) {
            _value = range.max;
        }
        range.start = _value;
        _component.invalidateComponentLayout();

        var changeEvent:UIEvent = new UIEvent(UIEvent.CHANGE);
        changeEvent.previousValue = _previousValue;
        changeEvent.value = _value;
        _component.dispatch(changeEvent);
    }
}

@:dox(hide) @:noCompletion
private class RangeEnd extends DataBehaviour {
    public override function validateData() {
        var range:Range = cast(_component, Range);
        if (_value != null && _value < range.min) {
            _value = range.min;
        } else if (_value != null && _value > range.max) {
            _value = range.max;
        }

        range.end = _value;
        _component.invalidateComponentLayout();

        var changeEvent:UIEvent = new UIEvent(UIEvent.CHANGE);
        changeEvent.previousValue = _previousValue;
        changeEvent.value = _value;
        _component.dispatch(changeEvent);
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class AllowInteraction extends DefaultBehaviour {
    public override function get():Variant {
        return (_component._internalEvents != null);
    }

    public override function set(value:Variant) {
        if (_component.native == true) {
            return;
        }

        if (value == true) {
            _component.registerInternalEvents(Events);
        } else {
            _component.unregisterInternalEvents();
        }
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.components.Range)
private class Events extends haxe.ui.events.Events {
    private var _range:Range;

    public function new(range:Range) {
        super(range);
        _range = range;
        register();
    }

    public override function register() {
        _range.registerEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
    }

    public override function unregister() {
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
        var pt:Point = new Point(e.screenX - _range.screenLeft, e.screenY - _range.screenTop);
        var pos:Float = _range.posFromCoord(pt);
        applyPos(pos);
    }

    private function applyPos(pos:Float) {
        pos = MathUtil.round(pos, _range.precision);
        if (_range.step > 0) {
            pos = Math.fceil(pos / _range.step) * _range.step;
        }

        if ((_range is Progress)) {
            cast(_range, Progress).pos = pos;
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

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class RangeBuilder extends CompositeBuilder {
    public function new(component:Component) {
        super(component);
        showWarning();
    }

    public override function create() {
        super.create();
        if (_component.findComponent("${_component.cssName}-value") == null) {
            var v = new Component();
            v.id = '${_component.cssName}-value';
            v.addClass('${_component.cssName}-value', false);
            _component.addComponent(v);
        }
    }
    
    private function showWarning() {
        var name = _component.className.split(".").pop();
        trace("WARNING: trying to create an instance of '" + name + "' directly, use either 'Horizontal" + name + "' or 'Vertical" + name + "'");
    }
}