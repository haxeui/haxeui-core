package haxe.ui.components;

import haxe.ui.animation.AnimationManager;
import haxe.ui.core.Behaviour;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.util.Variant;

/**
 Encapsulates shared functionality of both vertical and horizontal scrollbar components
**/
@:dox(icon = "/icons/ui-scroll-bar-horizontal.png")
class Scroll extends InteractiveComponent {
    private var _incButton:Button;
    private var _deincButton:Button;
    private var _thumb:Button;

    public function new() {
        super();
        allowFocus = false;
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "min" => new ScrollDefaultMinBehaviour(this),
            "max" => new ScrollDefaultMaxBehaviour(this),
            "pos" => new ScrollDefaultPosBehaviour(this),
            "pageSize" => new ScrollDefaultPageSizeBehaviour(this)
        ]);
    }

    private override function createChildren() {
        if (componentWidth <= 0) {
            componentWidth = 100;
        }
        if (componentHeight <= 0) {
            componentHeight = 100;
        }

        registerEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);

        if (_deincButton == null) {
            _deincButton = new Button();
            _deincButton.scriptAccess = false;
            _deincButton.customStyle.native = false;
            //_deincButton.clipContent = false;
            _deincButton.id = "scroll-deinc-button";
            _deincButton.addClass("deinc");
            _deincButton.allowFocus = false;
            _deincButton.repeater = true;
            _deincButton.registerEvent(MouseEvent.CLICK, _onDeinc);
            addComponent(_deincButton);
        }

        if (_incButton == null) {
            _incButton = new Button();
            _incButton.scriptAccess = false;
            _incButton.customStyle.native = false;
            //_incButton.clipContent = false;
            _incButton.id = "scroll-inc-button";
            _incButton.addClass("inc");
            _incButton.allowFocus = false;
            _incButton.repeater = true;
            _incButton.registerEvent(MouseEvent.CLICK, _onInc);
            addComponent(_incButton);
        }

        if (_thumb == null) {
            _thumb = new Button();
            _thumb.scriptAccess = false;
            _thumb.customStyle.native = false;
            //_thumb.clipContent = false;
            _thumb.id = "scroll-thumb-button";
            _thumb.addClass("thumb");
            _thumb.allowFocus = false;
            _thumb.remainPressed = true;
            _thumb.registerEvent(MouseEvent.MOUSE_DOWN, _onThumbMouseDown);
            addComponent(_thumb);
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
    // Validation
    //***********************************************************************************************************

    private override function validateData() {
        if (behaviourGet("min") != _min) {
            behaviourSet("min", _min);
        }

        if (behaviourGet("max") != _max) {
            behaviourSet("max", _max);
        }

        if (behaviourGet("pageSize") != _pageSize) {
            behaviourSet("pageSize", _pageSize);
        }

        if (behaviourGet("pos") != _pos) {
            behaviourSet("pos", _pos);

            var changeEvent:UIEvent = new UIEvent(UIEvent.CHANGE);
            dispatch(changeEvent);
            handleBindings(["value"]);
        }
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    private var _pos:Float = 0;
    /**
     The current value of the scrollbar
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

        if (value != _pos) {
            _pos = value;
            invalidateComponentData();
        }
        return value;
    }

    private function animatePos(value:Float) {
        if (animatable == false) {
            pos = value;
            return;
        }

        var animationId:String = getClassProperty("animation.pos");
        if (animationId == null) {
            pos = value;
            return;
        }

        AnimationManager.instance.run(animationId, ["target" => this], ["pos" => value]);
    }

    private var _min:Float = 0;
    /**
     The minimum value the scrollbar can hold
    **/
    @:dox(group = "Value related properties and methods")
    @bindable @clonable public var min(get, set):Float;
    private function get_min():Float {
        return _min;
    }
    private function set_min(value:Float):Float {
        if (value != _min) {
            _min = value;
            if (_pos < _min) {
                _pos = _min;
            }

            invalidateComponentData();
        }
        return value;
    }

    private var _max:Float = 100;
    /**
     The maximum value the scrollbar can hold
    **/
    @:dox(group = "Value related properties and methods")
    @bindable @clonable public var max(get, set):Float;
    private function get_max():Float {
        return _max;
    }
    private function set_max(value:Float):Float {
        if (value != _max) {
            _max = value;
            if (_pos > _max) {
                _pos = _max;
            }

            invalidateComponentData();
        }
        return value;
    }

    private var _pageSize:Float = 0;
    /**
     How big a page is considered to be in this scrollbar (affects the size of the thumb)
    **/
    @:dox(group = "Value related properties and methods")
    @bindable @clonable public var pageSize(get, set):Float;
    private function get_pageSize():Float {
        return _pageSize;
    }
    private function set_pageSize(value:Float):Float {
        if (value == _pageSize) {
            return value;
        }

        _pageSize = value;
        invalidateComponentData();
        return value;
    }

    private var _incrementSize:Float = 20;
    /**
     What value to add to or subtract from the scrollbars value when using the up/down or left/right buttons
    **/
    @:dox(group = "Value related properties and methods")
    @bindable @clonable public var incrementSize(get, set):Float;
    private function get_incrementSize():Float {
        return _incrementSize;
    }
    private function set_incrementSize(value:Float):Float {
        if (_incrementSize == value) {
            return value;
        }
        _incrementSize = value;
        return value;
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    var _mouseDownOffset:Float = -1;
    private function _onDeinc(event:MouseEvent) {
        deincrementValue();
    }

    private function _onInc(event:MouseEvent) {
        incrementValue();
    }

    private function _onThumbMouseDown(event:MouseEvent) {
        screen.registerEvent(MouseEvent.MOUSE_UP, _onScreenMouseUp);
        screen.registerEvent(MouseEvent.MOUSE_MOVE, _onScreenMouseMove);
    }

    private function _onScreenMouseMove(event:MouseEvent) {
    }

    private function _onScreenMouseUp(event:MouseEvent) {
        _mouseDownOffset = -1;
        screen.unregisterEvent(MouseEvent.MOUSE_UP, _onScreenMouseUp);
        screen.unregisterEvent(MouseEvent.MOUSE_MOVE, _onScreenMouseMove);
    }

    private function _onMouseDown(event:MouseEvent) {
    }

    //******************************************************************************************
    // Helpers
    //******************************************************************************************
    /**
     Deincrement the scrollbars value
    **/
    @:dox(group = "Value related properties and methods")
    public function deincrementValue() {
        //pos -= _incrementSize;
        animatePos(pos - _incrementSize);
    }

    /**
     Increment the scrollbars value
    **/
    @:dox(group = "Value related properties and methods")
    public function incrementValue() {
        //pos += _incrementSize;
        animatePos(pos + _incrementSize);
    }
}

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.Scroll)
class ScrollDefaultMinBehaviour extends Behaviour {
    private var _value:Float = 0;

    public override function set(value:Variant) {
        if (_value == value) {
            _value = value;
        }
        _value = value;

        var scroll:Scroll = cast _component;
        scroll.invalidateComponentLayout();
    }

    public override function get():Variant {
        return _value;
    }
}

@:dox(hide)
@:access(haxe.ui.components.Scroll)
class ScrollDefaultMaxBehaviour extends Behaviour {
    private var _value:Float = 0;

    public override function set(value:Variant) {
        if (_value == value) {
            return;
        }
        _value = value;

        var scroll:Scroll = cast _component;
        scroll.invalidateComponentLayout();
    }

    public override function get():Variant {
        return _value;
    }
}

@:dox(hide)
@:access(haxe.ui.components.Scroll)
class ScrollDefaultPosBehaviour extends Behaviour {
    private var _value:Float = 0;

    public override function set(value:Variant) {
        if (_value == value) {
            return;
        }
        _value = value;

        var scroll:Scroll = cast _component;
        scroll.invalidateComponentLayout();
    }

    public override function get():Variant {
        return _value;
    }
}

@:dox(hide)
@:access(haxe.ui.components.Scroll)
class ScrollDefaultPageSizeBehaviour extends Behaviour {
    private var _value:Float = 0;

    public override function set(value:Variant) {
        if (_value == value) {
            return;
        }
        _value = value;

        var scroll:Scroll = cast _component;
        scroll.invalidateComponentLayout();
    }

    public override function get():Variant {
        return _value;
    }
}
