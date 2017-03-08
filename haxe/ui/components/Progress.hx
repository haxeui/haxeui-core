package haxe.ui.components;

import haxe.ui.animation.AnimationManager;
import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.UIEvent;
import haxe.ui.util.Variant;

/**
 Encapsulates shared functionality of both vertical and horizontal progressbar components
**/
@:dox(icon = "/icons/ui-progress-bar.png")
class Progress extends InteractiveComponent {
    private var _value:Component;

    public function new() {
        super();
        allowFocus = false;
        addClass("progress");

    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "min" => new ProgressDefaultMinBehaviour(this),
            "max" => new ProgressDefaultMaxBehaviour(this),
            "pos" => new ProgressDefaultPosBehaviour(this),
            "rangeStart" => new ProgressDefaultRangeStartBehaviour(this),
            "rangeEnd" => new ProgressDefaultRangeEndBehaviour(this),
            "indeterminate" => new ProgressDefaultIndeterminateBehaviour(this)
        ]);
    }

    private override function create() {
        super.create();

        behaviourSet("min", _min);
        behaviourSet("max", _max);
        behaviourSet("pos", _pos);
        behaviourSet("indeterminate", _indeterminate);
    }

    private override function createChildren() {
        if (_value == null) {
            _value = new Component();
            _value.id = "progress-value";
            _value.addClass("progress-value");
            #if flambe
            _value.pixelSnapping = false;
            #end
            addComponent(_value);
        }
    }

    private override function destroyChildren() {
        if (_value != null) {
            removeComponent(_value);
            _value = null;
        }
    }

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function get_value():Variant {
        return pos;
    }

    private override function set_value(value:Variant):Variant {
        pos = value;
        return value;
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    private var _pos:Float = 0;
    /**
     The current value of the progressbar
    **/
    @:dox(group = "Value related properties and methods")
    @bindable @clonable public var pos(get, set):Float;
    private function get_pos():Float {
        return _pos;
    }
    private function set_pos(value:Float):Float {
        if (_ready) { // only enforce constraints when ready as xml attrs can come in in any order
            if (value < _min) {
                value = _min;
            }
            if (value > _max) {
                value = _max;
            }
        }

        if (value == _pos) {
            return value;
        }

        _pos = value;
        behaviourSet("pos", value);
        var changeEvent:UIEvent = new UIEvent(UIEvent.CHANGE);
        dispatch(changeEvent);
        handleBindings(["value"]);
        return value;
    }

    private var _min:Float = 0;
    /**
     The minimum value the progress can hold
    **/
    @:dox(group = "Value related properties and methods")
    @bindable @clonable public var min(get, set):Float;
    private function get_min():Float {
        return _min;
    }
    private function set_min(value:Float):Float {
        if (value == _min) {
            return value;
        }

        _min = value;
        behaviourSet("min", value);
        return value;
    }

    private var _max:Float = 100;
    /**
     The maximum value the progress can hold
    **/
    @:dox(group = "Value related properties and methods")
    @bindable @clonable public var max(get, set):Float;
    private function get_max():Float {
        return _max;
    }
    private function set_max(value:Float):Float {
        if (value == _max) {
            return value;
        }

        _max = value;
        behaviourSet("max", value);
        return value;
    }

    private var _rangeStart:Float = 0;
    /**
     The start of the progressbars range value
    **/
    @:dox(group = "Range related properties and methods")
    @bindable @clonable public var rangeStart(get, set):Float;
    private function get_rangeStart():Float {
        return _rangeStart;
    }
    private function set_rangeStart(value:Float):Float {
        if (_ready) {
            if (value < _min) {
                value = _min;
            }
            if (value >= _rangeEnd) {
                value = _rangeEnd;
            }
        }

        _rangeStart = value;
        behaviourSet("rangeStart", value);
        return value;
    }

    private var _rangeEnd:Float = 0;
    /**
     The end of the progressbars range value
    **/
    @:dox(group = "Range related properties and methods")
    @bindable @clonable public var rangeEnd(get, set):Float;
    private function get_rangeEnd():Float {
        return _rangeEnd;
    }
    private function set_rangeEnd(value:Float):Float {
        if (_ready) {
            if (value > _max) {
                value = _max;
            }
            if (value <= _rangeStart) {
                value = _rangeStart;
            }
        }

        _rangeEnd = value;
        behaviourSet("rangeEnd", value);
        return value;
    }

    private var _indeterminate:Bool = false;
    /**
     Whether to show this progress bar as an animated "indeterminate" progressbar
    **/
    @:dox(group = "Indeterminate mode related properties")
    @bindable @clonable public var indeterminate(get, set):Bool;
    private function get_indeterminate():Bool {
        return _indeterminate;
    }
    private function set_indeterminate(value:Bool):Bool {
        if (value == _indeterminate) {
            return value;
        }

        _indeterminate = value;
        behaviourSet("indeterminate", value);

        return value;
    }

    private function startIndeterminateAnimation() {
        var animationId:String = getClassProperty("animation.indeterminate");
        if (animationId == null) {
            return;
        }
        AnimationManager.instance.loop(animationId, ["target" => this]);
    }

    private function stopIndeterminateAnimation() {

    }
}

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.Progress)
class ProgressDefaultMinBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var progress:Progress = cast _component;
        progress.invalidateLayout();
    }
}

@:dox(hide)
@:access(haxe.ui.components.Progress)
class ProgressDefaultMaxBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var progress:Progress = cast _component;
        progress.invalidateLayout();
    }
}

@:dox(hide)
@:access(haxe.ui.components.Progress)
class ProgressDefaultPosBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var progress:Progress = cast _component;
        progress.invalidateLayout();
    }
}

@:dox(hide)
@:access(haxe.ui.components.Progress)
class ProgressDefaultRangeStartBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var progress:Progress = cast _component;
        progress.invalidateLayout();
    }
}

@:dox(hide)
@:access(haxe.ui.components.Progress)
class ProgressDefaultRangeEndBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var progress:Progress = cast _component;
        progress.invalidateLayout();
    }
}

@:dox(hide)
@:access(haxe.ui.components.Progress)
class ProgressDefaultIndeterminateBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var progress:Progress = cast _component;
        if (progress._indeterminate == true) {
            progress.startIndeterminateAnimation();
        } else {
            progress.stopIndeterminateAnimation();
        }

    }
}