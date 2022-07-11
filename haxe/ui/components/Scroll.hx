package haxe.ui.components;

import haxe.ui.events.Events;
import haxe.ui.events.ScrollEvent;
import haxe.ui.util.Variant;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.core.IDirectionalComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.behaviours.LayoutBehaviour;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Point;

/**
 * A scrollbar component, like the ones you see in a browser.
 */
class Scroll extends InteractiveComponent implements IDirectionalComponent {

    /**
     * Creates a new scrollbar.
     */
    private function new() {
        super();
        cascadeActive = true;
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************

    /**
     * A minimum value to calculate the position of the thumb from. defaults to 0.
     */
    @:behaviour(ScrollMinMaxBehaviour, 0)       public var min:Float;

    /**
     * A maximum value to calculate the position of the thumb from. defaults to 100.
     */
    @:behaviour(ScrollMinMaxBehaviour, 100)     public var max:Float;

    /**
     * When pressing on the scrollbar itself, decides how much should the thumb jump towards the mouse's position:
     * 
     * 0 - no jump (default)
     * 5 - jump 5 pixels towards the mouse's position
     * -5 - jump 5 pixels away from the mouse's position
     *
     * 
     * also decides the width/height of the thumb itself, depending on the orientation. when values are below 0, 
     * the default thumb is used
     */
    @:behaviour(LayoutBehaviour, 0)             public var pageSize:Float;

    /**
     * The current position of the thumb inside the scrollbar.
     */
    @:behaviour(ScrollValueBehaviour, 0)        public var pos:Float;

    /**
     * a stepping value to snap the thumb to, visually:
     * 
     * if pos is 7 and step is 2, the thumb will be moved to 8
     */
    @:behaviour(DefaultBehaviour, 20)           public var increment:Float; // TODO: should calc, 20 is too high if there are, say, 30 items

    //***********************************************************************************************************
    // Private API
    //***********************************************************************************************************
    private function posFromCoord(coord:Point):Float {
        return behaviours.call("posFromCoord", coord);
    }

    private function applyPageFromCoord(coord:Point):Float {
        return behaviours.call("applyPageFromCoord", coord);
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createChildren() {
        createButton("deinc", true).repeater = true;
        createButton("inc", true).repeater = true;
        createButton("thumb").remainPressed = true;

        registerInternalEvents(Events);
    }

    //***********************************************************************************************************
    // Helpers
    //***********************************************************************************************************
    private function createButton(type:String, hidden:Bool = false):Button {
        var b = findComponent('scroll-${type}-button', Button);
        if (b == null) {
            b = new Button();
            b.hidden = hidden;
            b.scriptAccess = false;
            b.customStyle.native = false;
            b.id = 'scroll-${type}-button';
            b.addClass(type);
            b.allowFocus = false;
            addComponent(b);
        }
        return b;
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.components.Scroll)
private class Events extends haxe.ui.events.Events  {
    private var _scroll:Scroll;
    private var _deincButton:Button;
    private var _incButton:Button;
    private var _thumb:Button;

    public function new(scroll:Scroll) {
        super(scroll);
        _scroll = scroll;
        _deincButton = _scroll.findComponent("scroll-deinc-button");
        _incButton = _scroll.findComponent("scroll-inc-button");
        _thumb = _scroll.findComponent("scroll-thumb-button");
    }

    public override function register() {
        if (hasEvent(MouseEvent.MOUSE_DOWN, onMouseDown) == false) {
            registerEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        }
        if (_deincButton != null && _deincButton.hasEvent(MouseEvent.CLICK, onDeinc) == false) {
            _deincButton.registerEvent(MouseEvent.CLICK, onDeinc);
        }
        if (_incButton != null && _incButton.hasEvent(MouseEvent.CLICK, onInc) == false) {
            _incButton.registerEvent(MouseEvent.CLICK, onInc);
        }
        if (_thumb != null && _thumb.hasEvent(MouseEvent.MOUSE_DOWN, onThumbMouseDown) == false) {
            _thumb.registerEvent(MouseEvent.MOUSE_DOWN, onThumbMouseDown);
        }
    }

    public override function unregister() {
        unregisterEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        if (_deincButton != null) {
            _deincButton.unregisterEvent(MouseEvent.CLICK, onDeinc);
        }
        if (_incButton != null) {
            _incButton.unregisterEvent(MouseEvent.CLICK, onInc);
        }
        if (_thumb != null) {
            _thumb.unregisterEvent(MouseEvent.MOUSE_DOWN, onThumbMouseDown);
        }
    }

    private function onMouseDown(event:MouseEvent) {
        // if mouse isn't pressing _deincButton or _incButton...
        var componentOffset = _scroll.getComponentOffset();
        if (_deincButton.hitTest(event.screenX - componentOffset.x, event.screenY - componentOffset.y) == false
            && _incButton.hitTest(event.screenX - componentOffset.x, event.screenY - componentOffset.y) == false) {
            _scroll.applyPageFromCoord(new Point(event.screenX - componentOffset.x, event.screenY - componentOffset.y));
        }
    }

    private function onDeinc(event:MouseEvent) {
        _scroll.pos -= _scroll.increment;
    }

    private function onInc(event:MouseEvent) {
        _scroll.pos += _scroll.increment;
    }

    private var _mouseDownOffset:Point;
    private function onThumbMouseDown(event:MouseEvent) {
        //event.cancel();

        _mouseDownOffset = new Point();
        _mouseDownOffset.x = event.screenX - _thumb.left + _scroll.layout.paddingLeft;
        _mouseDownOffset.y = event.screenY - _thumb.top + _scroll.layout.paddingTop;

        _scroll.screen.registerEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
        _scroll.screen.registerEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
    }

    private function onScreenMouseUp(event:MouseEvent) {
        _mouseDownOffset = null;
        _scroll.screen.unregisterEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
        _scroll.screen.unregisterEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
    }

    private function onScreenMouseMove(event:MouseEvent) {
        if (_mouseDownOffset == null) {
            return;
        }

        var coord = new Point(event.screenX - _mouseDownOffset.x, event.screenY - _mouseDownOffset.y);
        _scroll.pos = _scroll.posFromCoord(coord);
    }
}

@:dox(hide) @:noCompletion
private class ScrollValueBehaviour extends DataBehaviour {
    public override function set(value:Variant) {
        if (value == get()) {
            return;
        }

        super.set(value);
        _component.invalidateComponentLayout();
    }

    private override function validateData() {
        var scroll:Scroll = cast(_component, Scroll);
        var pos:Float = scroll.pos;
        var min:Float = scroll.min;
        var max:Float = scroll.max;
        if (pos < min) {
            scroll.pos = min;
        } else  if (pos > max) {
            scroll.pos = max;
        }

        var changeEvent:UIEvent = new UIEvent(UIEvent.CHANGE);
        scroll.dispatch(changeEvent);
        
        var scrollEvent:ScrollEvent = new ScrollEvent(ScrollEvent.SCROLL);
        scroll.dispatch(scrollEvent);
    }
}

@:dox(hide) @:noCompletion
private class ScrollMinMaxBehaviour extends DataBehaviour {
    public override function set(value:Variant) {
        if (value == get()) {
            return;
        }

        super.set(value);
        _component.invalidateComponentLayout();
    }

    private override function validateData() {
        var scroll:Scroll = cast(_component, Scroll);
        var pos:Float = scroll.pos;
        var min:Float = scroll.min;
        var max:Float = scroll.max;
        if (pos < min) {
            scroll.pos = min;
        } else  if (pos > max) {
            scroll.pos = max;
        }

        var changeEvent:UIEvent = new UIEvent(UIEvent.CHANGE);
        scroll.dispatch(changeEvent);
    }
}