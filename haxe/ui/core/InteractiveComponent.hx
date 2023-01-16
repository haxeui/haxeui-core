package haxe.ui.core;

import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.core.IValueComponent;
import haxe.ui.events.FocusEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.focus.IFocusable;

/**
 A component that can be interacted with and gain input focus via either mouse or keyboard
**/
@:access(haxe.ui.events.Events)
class InteractiveComponent extends Component implements IFocusable implements IValueComponent {
    public var actionRepeatInterval = 100;
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(DefaultBehaviour, true)      public var allowInteraction:Bool;

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
            eventType = FocusEvent.FOCUS_IN;
            FocusManager.instance.focus = cast(this, IFocusable);

            // if we are focusing lets see if there is a ancestor scrollview we might want to scroll into view
            var scrollview = findScroller();
            if (scrollview != null) {
                scrollview.ensureVisible(this);
            }
        } else {
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
            if ((child is IFocusable)) {
                cast(child, IFocusable).allowFocus = value;
            }
        }
        return value;
    }

    private var _autoFocus:Bool = true;
    /**
     Whether this component is allowed to gain focus automatically 
    **/
    public var autoFocus(get, set):Bool;
    private function get_autoFocus():Bool {
        return _autoFocus;
    }
    private function set_autoFocus(value:Bool):Bool {
        if (_autoFocus == value) {
            return value;
        }

        _autoFocus = value;
        for (child in childComponents) {
            if ((child is IFocusable)) {
                cast(child, IFocusable).autoFocus = value;
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
