package haxe.ui.focus;

import haxe.ui.backend.FocusManagerImpl;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.focus.IFocusable;

#if (haxe_ver >= 4.2)
import Std.isOfType;
#else
import Std.is as isOfType;
#end

#if haxeui_expose_all
@:expose
#end
class FocusManager extends FocusManagerImpl {
    private static var _instance:FocusManager;
    public static var instance(get, null):FocusManager;
    private static function get_instance():FocusManager {
        if (_instance == null) {
            _instance = new FocusManager();
        }
        return _instance;
    }

    //****************************************************************************************************
    // Instance
    //****************************************************************************************************
    public var autoFocus:Bool = true; // whether or not to automatically set focus to the first interactive component in a view when its added
    public var enabled:Bool = true; // whether or not to allow focus management globally
    
    private var _applicators:Array<IFocusApplicator> = [];
    
    public function new() {
        super();
        _applicators.push(new StyleFocusApplicator());
        //_applicators.push(new BoxFocusApplicator());
        
        Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
    }

    private function onScreenMouseDown(event:MouseEvent) {
        var list = Screen.instance.findComponentsUnderPoint(event.screenX, event.screenY);
        for (l in list) {
            // A label is focusable only when it takes focus (`Label.focusableLinks`).
            if (isOfType(l, IFocusable) && !(isOfType(l, haxe.ui.components.Label) && cast(l, IFocusable).allowFocus == false)) {
                return;
            }
        }
        
        focus = null;
    }
    
    public function pushView(view:Component) {
        if (hasFocusableItem(view)) {
            unfocusRemembered();
        }
        if (autoFocus == true) {
            focusOnFirstInteractive(view);
            view.registerEvent(UIEvent.READY, onViewReady);
        }
    }

    private function onViewReady(e:UIEvent) {
        e.target.unregisterEvent(UIEvent.READY, onViewReady);
        if (hasFocusableItem(e.target)) {
            unfocusRemembered();
            focusOnFirstInteractive(e.target);
        }
    }
    
    /**
        Unfocuses each view's remembered focus, which stays remembered to give back when the view above it closes.
        From a copy: unfocusing a component clears the top view's focus, which forgets the top view's.
    **/
    private function unfocusRemembered() {
        var remembered = [for (f in _lastFocuses) f];
        for (f in remembered) {
            f.focus = false;
            unapplyFocus(cast f);
        }
    }

    private function hasFocusableItem(view:Component):Bool {
        var list = [];
        buildFocusableList(view, list);
        return list.length != 0;
    }
    
    private function focusOnFirstInteractive(view:Component) {
        var list = [];
        buildFocusableList(view, list, true);
        if (list.length > 0) {
            list[0].focus = true;
            return list[0];
        }
        return null;
    }
    
    public function removeView(view:Component) {
        _lastFocuses.remove(view);
        var top = Screen.instance.topComponent;
        if (top == null) {
            return;
        }
        if (_lastFocuses.exists(top)) {
            focus = _lastFocuses.get(top);
        }
    }

    public var focus(get, set):IFocusable;
    private function get_focus():IFocusable {
        var top = Screen.instance.topComponent;
        if (top == null) {
            return null;
        }
        return buildFocusableList(top, null);
    }
    
    private var _lastFocuses:Map<Component, IFocusable> = new Map<Component, IFocusable>();
    private function set_focus(value:IFocusable):IFocusable {
        if (value != null) {
            var c = cast(value, Component);
            var root = c.rootComponent;
            var currentFocus = buildFocusableList(root, null);
            if (currentFocus != null && currentFocus != value) {
                unapplyFocus(cast currentFocus);
                currentFocus.focus = false;
            }
            // Held here: unfocusing it clears the top view's focus, which forgets it.
            var last = _lastFocuses.get(root);
            if (last != null && last != value) {
                last.focus = false;
                unapplyFocus(cast last);
            }

            _lastFocuses.set(root, value);
            applyFocus(cast value);
        } else {
            var top = Screen.instance.topComponent;
            if (top == null) {
                return null;
            }
            var last = _lastFocuses.get(top);
            if (last != null) {
                // Nothing has focus now, so there's nothing to give back when a view above this one closes: a text
                // field put away with the on-screen keyboard came back, keyboard and all, after a menu closed.
                // Forgotten first, as unfocusing it comes back here.
                _lastFocuses.remove(top);
                last.focus = false;
                unapplyFocus(cast last);
            }
        }
        return value;
    }

    public function focusNext():Component {
        var top = Screen.instance.topComponent;
        var list:Array<IFocusable> = [];
        var currentFocus = buildFocusableList(top, list);

        var index = -1;
        if (currentFocus != null) {
            index = list.indexOf(currentFocus);
        }

        var nextIndex = index + 1;
        if (nextIndex > list.length - 1) {
            nextIndex = 0;
        }

        var nextFocus = list[nextIndex];
        focus = nextFocus;
        return cast nextFocus;
    }

    public function focusPrev():Component {
        var top = Screen.instance.topComponent;
        var list:Array<IFocusable> = [];
        var currentFocus = buildFocusableList(top, list);

        var index = -1;
        if (currentFocus != null) {
            index = list.indexOf(currentFocus);
        }

        var prevIndex = index - 1;
        if (prevIndex < 0) {
            prevIndex = list.length - 1;
        }

        var prevFocus = list[prevIndex];
        focus = prevFocus;
        return cast prevFocus;
    }

    private function buildFocusableList(c:Component, list:Array<IFocusable>, considerAutoFocus:Bool = false):IFocusable {
        if (!enabled) {
            return null;
        }
        var currentFocus = null;
        
        if (c == null || @:privateAccess c._isDisposed == true) {
            return null;
        }
        
        if (c.hidden == true) {
            return null;
        }
        
        if ((c is IFocusable)) {
            var f:IFocusable = cast c;
            if (considerAutoFocus == true && f.autoFocus == false) {
                return null;
            }
            if (f.allowFocus == true && f.disabled == false) {
                if (f.focus == true) {
                    currentFocus = f;
                }
                if (list != null) {
                    list.push(f);
                }
            }
        }

        var childList = c.childComponents.copy();
        childList.sort(function(c1, c2) {
            return c1.componentTabIndex - c2.componentTabIndex;
        });
        
        for (child in childList) {
            var f:IFocusable = buildFocusableList(child, list, considerAutoFocus);
            if (f != null) {
                currentFocus = f;
            }
        }
        return cast currentFocus;
    }
    
    private override function applyFocus(c:Component) {
        super.applyFocus(c);
        cast(c, IFocusable).focus = true;
        for (a in _applicators) {
            if (a.enabled == true) {
                a.apply(c);
            }
        }
    }
    
    private override function unapplyFocus(c:Component) {
        super.unapplyFocus(c);
        cast(c, IFocusable).focus = false;
        for (a in _applicators) {
            if (a.enabled == true) {
                a.unapply(c);
            }
        }
    }
}