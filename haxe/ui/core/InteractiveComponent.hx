package haxe.ui.core;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.containers.ScrollView;
import haxe.ui.events.FocusEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.focus.IFocusable;

/**
 A component that can be interacted with and gain input focus via either mouse or keyboard
**/
@:composite(InteractiveComponentEvents)
class InteractiveComponent extends Component implements IFocusable {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(AllowInteraction, true)      public var allowInteraction:Bool;
    
    private var _focus:Bool = false;
    /**
     Whether this component currently has focus

     *Note*: components that have focus will have an `:active` css psuedo class automatically added
    **/
    public var focus(get, set):Bool;
    private function get_focus():Bool {
        return _focus;
    }
    private function set_focus(value:Bool):Bool {
        if (_focus == value || allowFocus == false) {
            return value;
        }

        _focus = value;
        var eventType = null;
        if (_focus == true) {
            addClass(":active");
            eventType = FocusEvent.FOCUS_IN;
            FocusManager.instance.focus = cast(this, IFocusable);
            
            // if we are focusing lets see if there is a ancestor scrollview we might want to scroll into view
            var scrollview = findAncestor(ScrollView);
            if (scrollview != null) {
                scrollview.ensureVisible(this);
            }
        } else {
            removeClass(":active");
            eventType = FocusEvent.FOCUS_OUT;
            FocusManager.instance.focus = null;
        }
        invalidateComponentData();
        dispatch(new FocusEvent(eventType));
        return value;
    }

    private var _allowFocus:Bool = true;
    /**
     Whether this component is allowed to gain focus
    **/
    public var allowFocus(get, set):Bool;
    private function get_allowFocus():Bool {
        return _allowFocus;
    }
    private function set_allowFocus(value:Bool):Bool {
        if (_allowFocus == value) {
            return value;
        }

        _allowFocus = value;
        for (child in childComponents) {
            if (Std.is(child, IFocusable)) {
                cast(child, IFocusable).allowFocus = value;
            }
        }
        return value;
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:access(haxe.ui.core.Component)
private class AllowInteraction extends DataBehaviour {
    private override function validateData() {
        _component.registerInternalEvents(true);
        if (_value == false) {
            _component.customStyle.cursor = null;
            _component.handleFrameworkProperty("allowMouseInteraction", false);
        } else {
            _component.customStyle.cursor = "pointer";
            _component.handleFrameworkProperty("allowMouseInteraction", true);
        }
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class InteractiveComponentEvents extends haxe.ui.events.Events {
    private var _interactiveComponent:InteractiveComponent;
    
    public function new(interactiveComponent:InteractiveComponent) {
        super(interactiveComponent);
        _interactiveComponent = interactiveComponent;
    }
    
    public override function register() {
        if (_interactiveComponent.allowInteraction == true) {
            if (hasEvent(MouseEvent.MOUSE_OVER, onMouseOver) == false) {
                registerEvent(MouseEvent.MOUSE_OVER, onMouseOver);
            }
            if (hasEvent(MouseEvent.MOUSE_OUT, onMouseOut) == false) {
                registerEvent(MouseEvent.MOUSE_OUT, onMouseOut);
            }
            if (hasEvent(MouseEvent.MOUSE_DOWN, onMouseDown) == false) {
                registerEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
            }
        } else {
            unregister();
        }
    }
    
    public override function unregister() {
        unregisterEvent(MouseEvent.MOUSE_OVER, onMouseOver);
        unregisterEvent(MouseEvent.MOUSE_OUT, onMouseOut);
        unregisterEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
    }
    
    private function onMouseOver(event:MouseEvent) {
        _interactiveComponent.addClass(":hover");
    }
    
    private function onMouseOut(event:MouseEvent) {
        _interactiveComponent.removeClass(":hover");
    }
    
    private function onMouseDown(event:MouseEvent) {
        _interactiveComponent.addClass(":down");
    }
    
    private function onMouseUp(event:MouseEvent) {
        _interactiveComponent.removeClass(":up");
    }
}