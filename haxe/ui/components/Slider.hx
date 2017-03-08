package haxe.ui.components;

import haxe.ui.animation.Animation;
import haxe.ui.animation.AnimationManager;
import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.util.Variant;

/**
 Encapsulates shared functionality of both vertical and horizontal slider components
**/
@:dox(icon = "/icons/ui-slider-050.png")
class Slider extends InteractiveComponent {
    private var _valueBackground:Component;
    private var _value:Component;

    private var _rangeStartThumb:Button;
    private var _rangeEndThumb:Button;

    public function new() {
        super();
        allowFocus = false;
        addClass("slider");
        _behaviourUpdateOrder = ["min", "max", "pos"];
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "min" => new SliderDefaultMinBehaviour(this),
            "max" => new SliderDefaultMaxBehaviour(this),
            "pos" => new SliderDefaultPosBehaviour(this),
            "rangeStart" => new SliderDefaultRangeStartBehaviour(this),
            "rangeEnd" => new SliderDefaultRangeEndBehaviour(this)
        ]);
    }

    private override function create() {
        super.create();

        behaviourSet("min", _min);
        behaviourSet("max", _max);
        behaviourSet("pos", _pos);
    }

    private override function createChildren() {
        super.createChildren();

        if (_valueBackground == null) {
            _valueBackground = new Component();
            _valueBackground.id = "slider-value-background";
            _valueBackground.addClass("slider-value-background");
            addComponent(_valueBackground);
            _valueBackground.registerEvent(MouseEvent.MOUSE_DOWN, _onValueBackgroundMouseDown);
        }

        if (_value == null) {
            _value = new Component();
            _value.id = "slider-value";
            _value.addClass("slider-value");
            #if flambe
            _value.pixelSnapping = false;
            #end
            _valueBackground.addComponent(_value);
            _value.registerEvent(MouseEvent.MOUSE_DOWN, _onValueMouseDown);
        }

        if (_rangeEndThumb == null) {
            _rangeEndThumb = new Button();
            _rangeEndThumb.scriptAccess = false;
            _rangeEndThumb.customStyle.native = false;
            //_rangeEndThumb.clipContent = false;
            _rangeEndThumb.id = "slider-range-end-button";
            _rangeEndThumb.addClass("slider-button");
            _rangeEndThumb.remainPressed = true;
            addComponent(_rangeEndThumb);
            _rangeEndThumb.registerEvent(MouseEvent.MOUSE_DOWN, _onRangeEndThumbMouseDown);
        }
    }

    private override function destroyChildren() {
        if (_valueBackground != null) {
            if (_value != null) {
                _valueBackground.removeComponent(_value);
                _value = null;
            }
            removeComponent(_valueBackground);
            _valueBackground = null;
        }

        if (_rangeEndThumb != null) {
            removeComponent(_rangeEndThumb);
            _rangeEndThumb = null;
        }
        if (_rangeStartThumb != null) {
            removeComponent(_rangeStartThumb);
            _rangeStartThumb = null;
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
     The current value of the slider
    **/
    @:dox(group = "Value related properties and methods")
    @bindable @clonable public var pos(get, set):Float;
    private function get_pos():Float {
        return behaviourGet("pos");
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

    private var _currentAnimation:Animation;
    private function animatePos(value:Float, callback:Void->Void = null) {
        if (animatable == false) {
            pos = value;
            return;
        }

        var animationId:String = getClassProperty("animation.pos");
        if (animationId == null) {
            pos = value;
            return;
        }

        if (_currentAnimation != null) {
            _currentAnimation.stop();
        }
        
        _currentAnimation = AnimationManager.instance.run(animationId, ["target" => this], ["pos" => value], callback);
    }

    private var _min:Float = 0;
    /**
     The minimum value the slider can hold
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
     The maximum value the slider can hold
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
        behaviourSet("pos", _pos);
        return value;
    }

    private var _rangeStart:Float = 0;
    /**
     The start of the sliders range value
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
            if (value >= _rangeEnd - 1) { // TODO: calc this
                value = _rangeEnd - 1;
            }
        }
        if (value != _rangeStart) {
            if (_rangeStartThumb == null) {
                _rangeStartThumb = new Button();
                _rangeStartThumb.scriptAccess = false;
                _rangeStartThumb.native = false;
                //_rangeStartThumb.clipContent = false;
                _rangeStartThumb.id = "slider-range-start-button";
                _rangeStartThumb.addClass("slider-button");
                _rangeStartThumb.remainPressed = true;
                _rangeStartThumb.registerEvent(MouseEvent.MOUSE_DOWN, _onRangeStartThumbMouseDown);
                addComponent(_rangeStartThumb);
            }

            _rangeStart = value;
            invalidateLayout();
            handleBindings(["value"]);
        }

        return value;
    }

    private function animateRangeStart(value:Float) {
        if (animatable == false) {
            rangeStart = value;
            return;
        }

        var animationId:String = getClassProperty("animation.rangeStart");
        if (animationId == null) {
            rangeStart = value;
            return;
        }

        AnimationManager.instance.run(animationId, ["target" => this], ["rangeStart" => value]);
    }

    private var _rangeEnd:Float = 0;
    /**
     The end of the sliders range value
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
            if (value <= _rangeStart + 1) { // TODO: calc this
                value = _rangeStart + 1;
            }
        }
        if (value != _rangeEnd) {
            _rangeEnd = value;
            invalidateLayout();
            handleBindings(["value"]);
        }
        return value;
    }

    private function animateRangeEnd(value:Float) {
        if (animatable == false) {
            rangeEnd = value;
            return;
        }

        var animationId:String = getClassProperty("animation.rangeEnd");
        if (animationId == null) {
            rangeEnd = value;
            return;
        }

        AnimationManager.instance.run(animationId, ["target" => this], ["rangeEnd" => value]);
    }

    /**
     Allows setting the sliders start and end range at the same time
    **/
    @:dox(group = "Range related properties and methods")
    public function setRange(start:Float, end:Float) {
        if (start != _rangeStart) {
            _rangeStart = start;
        }
        if (end != _rangeEnd) {
            _rangeEnd = end;
        }
        invalidateLayout();
        handleBindings(["value"]);
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    var _mouseDownOffset:Float = -1;
    private var _activeThumb:Button;

    private function _onValueBackgroundMouseDown(event:MouseEvent) {

    }

    private function _onValueMouseDown(event:MouseEvent) {
        _activeThumb = null;
        screen.registerEvent(MouseEvent.MOUSE_UP, _onScreenMouseUp);
        screen.registerEvent(MouseEvent.MOUSE_MOVE, _onScreenMouseMove);
    }

    private function _onRangeEndThumbMouseDown(event:MouseEvent) {
        _activeThumb = _rangeEndThumb;
        screen.registerEvent(MouseEvent.MOUSE_UP, _onScreenMouseUp);
        screen.registerEvent(MouseEvent.MOUSE_MOVE, _onScreenMouseMove);
    }

    private function _onRangeStartThumbMouseDown(event:MouseEvent) {
        _activeThumb = _rangeStartThumb;
        screen.registerEvent(MouseEvent.MOUSE_UP, _onScreenMouseUp);
        screen.registerEvent(MouseEvent.MOUSE_MOVE, _onScreenMouseMove);
    }

    private function _onScreenMouseMove(event:MouseEvent) {
        if (_mouseDownOffset == -1) {
            return;
        }
        if (_currentAnimation != null && event.buttonDown == true) {
            _currentAnimation.stop();
        }
    }

    private function _onScreenMouseUp(event:MouseEvent) {
        _mouseDownOffset = -1;
        _activeThumb = null;
        screen.unregisterEvent(MouseEvent.MOUSE_UP, _onScreenMouseUp);
        screen.unregisterEvent(MouseEvent.MOUSE_MOVE, _onScreenMouseMove);
    }
}

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.Slider)
class SliderDefaultMinBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var slider:Slider = cast _component;
        slider.invalidateLayout();
    }
}

@:dox(hide)
@:access(haxe.ui.components.Slider)
class SliderDefaultMaxBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var slider:Slider = cast _component;
        slider.invalidateLayout();
    }
}

@:dox(hide)
@:access(haxe.ui.components.Slider)
class SliderDefaultPosBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var slider:Slider = cast _component;
        slider.invalidateLayout();
    }
    
    public override function get():Variant {
        return cast(_component, Slider)._pos;
    }
}

@:dox(hide)
@:access(haxe.ui.components.Slider)
class SliderDefaultRangeStartBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var slider:Slider = cast _component;
        slider.invalidateLayout();
    }
}

@:dox(hide)
@:access(haxe.ui.components.Slider)
class SliderDefaultRangeEndBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var slider:Slider = cast _component;
        slider.invalidateLayout();
    }
}