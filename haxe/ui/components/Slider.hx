package haxe.ui.components;

import haxe.ui.Toolkit;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.IDirectionalComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.Screen;
import haxe.ui.events.Events;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Point;
import haxe.ui.util.MathUtil;
import haxe.ui.util.Variant;

@:composite(SliderBuilder)
class Slider extends InteractiveComponent implements IDirectionalComponent {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(MinBehaviour, 0)         public var min:Float;
    @:clonable @:behaviour(MaxBehaviour, 100)       public var max:Float;
    @:clonable @:behaviour(DefaultBehaviour, null)  public var precision:Null<Int>;
    @:clonable @:behaviour(StartBehaviour, null)    public var start:Null<Float>;
    @:clonable @:behaviour(EndBehaviour, 0)         public var end:Float;
    @:clonable @:behaviour(PosBehaviour)            public var pos:Float;
    @:clonable @:value(pos)                         public var value:Dynamic;

    //***********************************************************************************************************
    // Private API
    //***********************************************************************************************************
    @:call(PosFromCoord)                            private function posFromCoord(coord:Point):Float;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.components.Slider)
@:access(haxe.ui.core.Component)
private class StartBehaviour extends DataBehaviour {
    private override function validateData() {
        var builder:SliderBuilder = cast(_component._compositeBuilder, SliderBuilder);
        if (_component.findComponent("start-thumb") == null) {
            builder.createThumb("start-thumb");
        }

        var slider:Slider = cast(_component, Slider);
        if (_value != null && _value < slider.min) {
            _value = slider.min;
        }

        if (_value != null && _value > slider.max) {
            _value = slider.max;
        }

        if (slider.precision != null) {
            _value = MathUtil.round(_value, slider.precision);
        }

        _component.findComponent(Range).start = _value;
        _component.invalidateComponentLayout();
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.components.Slider)
private class EndBehaviour extends DataBehaviour {
    private override function validateData() {
        var slider:Slider = cast(_component, Slider);
        if (_value != null && _value < slider.min) {
            _value = slider.min;
        }

        if (_value != null && _value > slider.max) {
            _value = slider.max;
        }

        if (slider.precision != null) {
            _value = MathUtil.round(_value, slider.precision);
        }

        _component.findComponent(Range).end = _value;
        cast(_component, Slider).pos = _value;
        _component.invalidateComponentLayout();
    }
}

@:dox(hide) @:noCompletion
private class MinBehaviour extends DataBehaviour {
    private override function validateData() {
        if (cast(_component, Slider).start == null) {
            _component.findComponent(Range).start = _value;
        }
        _component.findComponent(Range).min = _value;
        _component.invalidateComponentLayout();
    }
}

@:dox(hide) @:noCompletion
private class MaxBehaviour extends DataBehaviour {
    private override function validateData() {
        _component.findComponent(Range).max = _value;
        _component.invalidateComponentLayout();
    }
}

@:dox(hide) @:noCompletion
private class PosBehaviour extends DataBehaviour {
    public override function get():Variant {
        if (_component.isReady == false) {
            return _value;
        }
        return cast(_component, Slider).end;
    }

    private override function validateData() {
        cast(_component, Slider).end = _value;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.components.Range)
private class PosFromCoord extends Behaviour {
    public override function call(coord:Any = null):Variant {
        var range:Range = _component.findComponent(Range);
        return range.posFromCoord(coord);
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.components.Slider)
private class Events extends haxe.ui.events.Events  {
    private var _slider:Slider;

    private var _endThumb:Button;
    private var _startThumb:Button;
    private var _range:Range;

    private var _activeThumb:Button;

    public function new(slider:Slider) {
        super(slider);
        _slider = slider;
        _range = slider.findComponent(Range);
    }

    public override function register() {
        _startThumb = _slider.findComponent("start-thumb");
        if (_startThumb != null && _startThumb.hasEvent(MouseEvent.MOUSE_DOWN, onThumbMouseDown) == false) {
            _startThumb.registerEvent(MouseEvent.MOUSE_DOWN, onThumbMouseDown);
        }

        _endThumb = _slider.findComponent("end-thumb");
        if (_endThumb != null && _endThumb.hasEvent(MouseEvent.MOUSE_DOWN, onThumbMouseDown) == false) {
            _endThumb.registerEvent(MouseEvent.MOUSE_DOWN, onThumbMouseDown);
        }

        if (_range.hasEvent(MouseEvent.MOUSE_DOWN, onRangeMouseDown) == false) {
            _range.registerEvent(MouseEvent.MOUSE_DOWN, onRangeMouseDown);
        }
        if (_range.hasEvent(UIEvent.CHANGE, onRangeChange) == false) {
            _range.registerEvent(UIEvent.CHANGE, onRangeChange);
        }
    }

    public override function unregister() {
        if (_startThumb != null) {
            _startThumb.unregisterEvent(MouseEvent.MOUSE_DOWN, onThumbMouseDown);
        }

        if (_endThumb != null) {
            _endThumb.unregisterEvent(MouseEvent.MOUSE_DOWN, onThumbMouseDown);
        }

        _range.unregisterEvent(MouseEvent.MOUSE_DOWN, onRangeMouseDown);
        _range.unregisterEvent(UIEvent.CHANGE, onRangeChange);
    }

    private function onRangeChange(e:UIEvent) {
        _slider.dispatch(new UIEvent(UIEvent.CHANGE));
    }

    private function onRangeMouseDown(e:MouseEvent) {
        if (_startThumb != null && _startThumb.hitTest(e.screenX, e.screenY) == true) {
            return;
        }
        if (_endThumb != null && _endThumb.hitTest(e.screenX, e.screenY) == true) {
            return;
        }

        e.screenX *= Toolkit.scaleX;
        e.screenY *= Toolkit.scaleY;
        e.cancel();

        var coord:Point = new Point();
        coord.x = (e.screenX - _slider.screenLeft) - _slider.paddingLeft * Toolkit.scaleX;
        coord.y = (e.screenY - _slider.screenTop) - _slider.paddingTop * Toolkit.scaleY;
        var pos:Float = _slider.posFromCoord(coord);

        if (_startThumb == null) {
            _slider.pos = pos;
            startDrag(_endThumb, (_endThumb.actualComponentWidth / 2), (_endThumb.actualComponentHeight / 2));
            return;
        }

        var builder:SliderBuilder = cast(_slider._compositeBuilder, SliderBuilder);
        var d1 = _slider.end - _slider.start;
        var d2 = pos - _slider.start;
        if (d2 < d1 / 2) {
            pos -= builder.getStartOffset();
            _slider.start = pos;
            startDrag(_startThumb, (_startThumb.actualComponentWidth / 2), (_startThumb.actualComponentHeight / 2));
        } else if (d2 >= d1 / 2) {
            pos -= builder.getStartOffset();
            _slider.end = pos;
            startDrag(_endThumb, (_endThumb.actualComponentWidth / 2), (_endThumb.actualComponentHeight / 2));
        } else if (pos > _slider.start) {
            _slider.end = pos;
            startDrag(_endThumb, (_endThumb.actualComponentWidth / 2), (_endThumb.actualComponentHeight / 2));
        } else if (pos < _slider.end) {
            _slider.start = pos;
            startDrag(_startThumb, (_startThumb.actualComponentWidth / 2), (_startThumb.actualComponentHeight / 2));
        }
    }

    private var _offset:Point = null;
    private function onThumbMouseDown(e:MouseEvent) {
        e.cancel();
        startDrag(cast(e.target, Button), e.localX * Toolkit.scaleX, e.localY * Toolkit.scaleX);
    }

    private function startDrag(thumb:Button, offsetX:Float, offsetY:Float) {
        _offset = new Point(offsetX, offsetY);
        _activeThumb = thumb;
        Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
        Screen.instance.registerEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
    }

    private function onScreenMouseUp(e:MouseEvent) {
        _activeThumb = null;
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
    }

    private function onScreenMouseMove(e:MouseEvent) {
        e.screenX *= Toolkit.scaleX;
        e.screenY *= Toolkit.scaleY;
        var coord:Point = new Point();
        coord.x = (e.screenX - _slider.screenLeft - _offset.x) - (_slider.paddingLeft * Toolkit.scaleX) +  (_activeThumb.actualComponentWidth / 2);
        coord.y = (e.screenY - _slider.screenTop - _offset.y) - (_slider.paddingTop * Toolkit.scaleX) +  (_activeThumb.actualComponentHeight / 2);
        var pos:Float = _slider.posFromCoord(coord);

        var builder:SliderBuilder = cast(_slider._compositeBuilder, SliderBuilder);
        if (_activeThumb == _startThumb) {
            pos -= builder.getStartOffset();
            if (pos > _slider.end) {
                pos = _slider.end;
            }
            _slider.start = pos;
        } else if (_activeThumb == _endThumb) {
            pos -= builder.getStartOffset();
            _slider.end = pos;
        }
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class SliderBuilder extends CompositeBuilder {
    public override function create() {
        if (_component.findComponent("range") == null) {
            var v = createValueComponent();
            v.scriptAccess = false;
            v.id = "range";
            v.addClass("slider-value");
            v.start = v.end = 0;
            _component.addComponent(v);
        }

        createThumb("end-thumb");
    }

    public function getStartOffset():Float {
        return 0;
    }

    private function createValueComponent():Range {
        return null;
    }

    public function createThumb(id:String) {
        if (_component.findComponent(id) != null) {
            return;
        }

        var b = new Button();
        b.scriptAccess = false;
        b.id = id;
        b.addClass(id);
        b.remainPressed = true;
        _component.addComponent(b);

        _component.registerInternalEvents(Events, true); // call .register again as we might have a new thumb!
    }
}