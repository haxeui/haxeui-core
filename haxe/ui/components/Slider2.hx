package haxe.ui.components;

import haxe.ui.core.IDirectionalComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.Screen;
import haxe.ui.core.ValueBehaviour;
import haxe.ui.util.Point;
import haxe.ui.util.Variant;

class Slider2 extends InteractiveComponent implements IDirectionalComponent {
    public function new() {
        super();
    }
    
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(StartBehaviour) public var start:Float;
    @:behaviour(EndBehaviour)   public var end:Float;
    @:behaviour(EndBehaviour)   public var pos:Float;
    
    //***********************************************************************************************************
    // Private API
    //***********************************************************************************************************
    private function createValueComponent():Range {
        return null;
    }
    
    private function posFromCoord(coord:Point):Float {
        return findComponent(Range).behaviourCall("posFromCoord", coord);
    }
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private var _events:Events = null;
    private override function createChildren() {
        super.createChildren();
        if (findComponent("range") == null) {
            var v = createValueComponent();
            v.scriptAccess = false;
            v.id = "range";
            v.addClass("slider-value");
            v.start = v.end = 0;
            addComponent(v);
        }
        
        createThumb("end-thumb");
    }
    
    private override function destroyChildren() {
        super.destroyChildren();
        if (_events != null) {
            _events.unregister();
            _events = null;
        }
    }
    
    //***********************************************************************************************************
    // Helpers
    //***********************************************************************************************************
    private function createThumb(id:String) {
        if (findComponent(id) != null) {
            return;
        }
        
        var b = new Button();
        b.scriptAccess = false;
        b.id = id;
        b.addClass(id);
        b.includeInLayout = false;
        b.remainPressed = true;
        addComponent(b);
        
        if (_events == null) {
            _events = new Events(this);
        }
        _events.register();
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.components.Slider2)
private class StartBehaviour extends ValueBehaviour {
    public override function get():Variant {
        return _component.findComponent(Range).start;
    }
    
    public override function set(value:Variant) {
        if (value == _value) {
            return;
        }
        
        if (_component.findComponent("start-thumb") == null) {
            cast(_component, Slider2).createThumb("start-thumb");
        }
        
        _component.findComponent(Range).start = value;
        _component.invalidateLayout();
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.components.Slider2)
private class EndBehaviour extends ValueBehaviour {
    public override function get():Variant {
        return _component.findComponent(Range).end;
    }
    
    public override function set(value:Variant) {
        if (value == _value) {
            return;
        }
        
        _component.findComponent(Range).end = value;
        _component.invalidateLayout();
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.components.Slider2)
private class Events {
    private var _slider:Slider2;
    private var _endThumb:Button;
    private var _startThumb:Button;
    
    private var _activeThumb:Button;
    
    public function new(slider:Slider2) {
        _slider = slider;
    }
    
    public function register() {
        _startThumb = _slider.findComponent("start-thumb");
        if (_startThumb != null && _startThumb.hasEvent(MouseEvent.MOUSE_DOWN, onThumbMouseDown) == false) {
            _startThumb.registerEvent(MouseEvent.MOUSE_DOWN, onThumbMouseDown);
        }
        
        _endThumb = _slider.findComponent("end-thumb");
        if (_endThumb != null && _endThumb.hasEvent(MouseEvent.MOUSE_DOWN, onThumbMouseDown) == false) {
            _endThumb.registerEvent(MouseEvent.MOUSE_DOWN, onThumbMouseDown);
        }
    }
    
    public function unregister() {
        if (_startThumb != null) {
            _startThumb.unregisterEvent(MouseEvent.MOUSE_DOWN, onThumbMouseDown);
        }
        
        if (_endThumb != null) {
            _endThumb.unregisterEvent(MouseEvent.MOUSE_DOWN, onThumbMouseDown);
        }
    }
    
    private var _offset:Point = null;
    private function onThumbMouseDown(e:MouseEvent) {
        _offset = new Point(e.localX, e.localY);
        _activeThumb = cast(e.target, Button);

        Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
        Screen.instance.registerEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
    }
    
    private function onScreenMouseUp(e:MouseEvent) {
        _activeThumb = null;
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
    }
   
    private function onScreenMouseMove(e:MouseEvent) {
        var r:Range = _slider.findComponent(Range);
        
        var coord:Point = new Point();
        coord.x = (e.screenX - _slider.screenLeft - _offset.x) + (r.layout.paddingLeft + r.layout.paddingRight) - (_activeThumb.width / 2);
        coord.y = (e.screenY - _slider.screenTop - _offset.y) + (r.layout.paddingTop + r.layout.paddingBottom) - (_activeThumb.height / 2);
        var pos:Float = _slider.posFromCoord(coord);
        
        if (_activeThumb == _startThumb) {
            _slider.start = pos;
        } else if (_activeThumb == _endThumb) {
             _slider.end = pos;
        }
    }
    
}