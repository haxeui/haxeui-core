package haxe.ui.core;

import haxe.ui.actions.ActionManager;
import haxe.ui.actions.ActionType;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.events.FocusEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.focus.IFocusable;

/**
 A component that can be interacted with and gain input focus via either mouse or keyboard
**/
@:access(haxe.ui.events.Events)
class InteractiveComponent extends Component implements IFocusable {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(DefaultBehaviour, true)      public var allowInteraction:Bool;

    /*
    private function actionStart(type:ActionType):Bool {
        if (_internalEvents != null) {
            return _internalEvents.actionStart(type);
        }
        return false;
    }
    */
    
    /*
    private function actionEnd(type:ActionType):Bool {
        if (_internalEvents != null) {
            return _internalEvents.actionEnd(type);
        }
        return false;
    }
    */
    
    private var _activated:Bool = false;
    private var activated(get, set):Bool;
    private function get_activated():Bool {
        return _activated;
    }
    private function set_activated(value:Bool):Bool {
        if (value == _activated) {
            return value;
        }
        _activated = value;
        if (_activated == true) {
            @:privateAccess ActionManager.instance._activatedComponent = this;
            swapClass(":active", ":activatable");
        } else{
            @:privateAccess ActionManager.instance._activatedComponent = null;
            removeClass(":active");
        }
        return value;
    }
    
    private var requiresActivation(get, null):Bool;
    private function get_requiresActivation():Bool {
        return false;
    }
    
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
            if (ActionManager.instance.navigationMethod == NavigationMethod.REMOTE && requiresActivation == true) {
                addClass(":activatable");
            } else {
                addClass(":active");
            }
            eventType = FocusEvent.FOCUS_IN;
            FocusManager.instance.focus = cast(this, IFocusable);

            // if we are focusing lets see if there is a ancestor scrollview we might want to scroll into view
            var scrollview = findScroller();
            if (scrollview != null) {
                scrollview.ensureVisible(this);
            }
        } else {
            if (ActionManager.instance.navigationMethod == NavigationMethod.REMOTE && requiresActivation == true) {
                removeClass(":activatable");
            } else {
                removeClass(":active");
            }
            eventType = FocusEvent.FOCUS_OUT;
            FocusManager.instance.focus = null;
            activated = false;
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
            if ((child is IFocusable)) {
                cast(child, IFocusable).allowFocus = value;
            }
        }
        return value;
    }
    
    private function findScroller():IScrollView {
        var view:IScrollView = null;
        var ref:Component = this;
        while (ref != null) {
            if ((ref is IScrollView)) {
                view = cast(ref, IScrollView);
                break;
            }
            ref = ref.parentComponent;
        }
        return view;
    }
}
