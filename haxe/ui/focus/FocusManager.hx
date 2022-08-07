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
    
    private var _applicators:Array<IFocusApplicator> = [];
    
    public function new() {
        super();
        _applicators.push(new StyleFocusApplicator());
        //_applicators.push(new BoxFocusApplicator());
        
        #if haxeui_focus_out_on_click
        Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
        #end
    }

    #if haxeui_focus_out_on_click
    private function onScreenMouseDown(event:MouseEvent) {
        var list = Screen.instance.findComponentsUnderPoint(event.screenX, event.screenY);
        for (l in list) {
            if (isOfType(l, IFocusable)) {
                return;
            }
        }
        
        focus = null;
    }
    #end
    
    public function pushView(view:Component) {
        if (hasFocusableItem(view)) {
            for (k in _lastFocuses.keys()) {
                _lastFocuses.get(k).focus = false;
                unapplyFocus(cast _lastFocuses.get(k));
            }
        }
        if (autoFocus == true) {
            focusOnFirstInteractive(view);
            view.registerEvent(UIEvent.READY, onViewReady);
        }
    }

    private function onViewReady(e:UIEvent) {
        e.target.unregisterEvent(UIEvent.READY, onViewReady);
        if (hasFocusableItem(e.target)) {
            for (k in _lastFocuses.keys()) {
                _lastFocuses.get(k).focus = false;
                unapplyFocus(cast _lastFocuses.get(k));
            }
            focusOnFirstInteractive(e.target);
        }
    }
    
    private function hasFocusableItem(view:Component):Bool {
        var list = [];
        buildFocusableList(view, list);
        return list.length != 0;
    }
    
    private function focusOnFirstInteractive(view:Component) {
        var list = [];
        buildFocusableList(view, list);
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
            if (_lastFocuses.exists(root) && _lastFocuses.get(root) != value) {
                _lastFocuses.get(root).focus = false;
                unapplyFocus(cast _lastFocuses.get(root));
            }

            _lastFocuses.set(root, value);
            applyFocus(cast value);
        } else {
            var top = Screen.instance.topComponent;
            if (_lastFocuses.exists(top)) {
                _lastFocuses.get(top).focus = false;
                unapplyFocus(cast _lastFocuses.get(top));
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

    private function buildFocusableList(c:Component, list:Array<IFocusable>):IFocusable {
        var currentFocus = null;
        
        if (@:privateAccess c._isDisposed == true) {
            return null;
        }
        
        if (c.hidden == true) {
            return null;
        }
        
        if ((c is IFocusable)) {
            var f:IFocusable = cast c;
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
            var f:IFocusable = buildFocusableList(child, list);
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